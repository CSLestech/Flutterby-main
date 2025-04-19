from flask import Flask, request, jsonify
import joblib
import torch
from torchvision import transforms
from PIL import Image
from transformers import DeiTForImageClassification
import timm

# === 1. Device setup ===
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# === 2. Load Mini Identifier Model ===
mini_identifier_model = DeiTForImageClassification.from_pretrained(
    "facebook/deit-base-distilled-patch16-224", 
    num_labels=2  # Binary classification
)
mini_identifier_model.load_state_dict(torch.load("deit_chicken_classifier.pth", map_location=device))
mini_identifier_model.to(device)
mini_identifier_model.eval()

# === 3. Load SVM Model ===
svm_model = joblib.load("svm_model_20250417_191204.pkl")

# === 4. Load DeiT Feature Extractor ===
deit = timm.create_model('deit_tiny_patch16_224', pretrained=True)
deit.reset_classifier(0)  # Remove the classification head
deit.eval()
deit.to(device)

# === 5. Transform ===
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5] * 3, std=[0.5] * 3)
])

# === 6. Flask App ===
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image = Image.open(request.files['image']).convert("RGB")
    img_tensor = transform(image).unsqueeze(0).to(device)

    # Step 1: Check if the image is a chicken breast
    with torch.no_grad():
        outputs = mini_identifier_model(img_tensor).logits
        is_chicken_breast = torch.argmax(outputs, dim=1).item() == 1  # Assuming class 1 is "chicken breast"

    if not is_chicken_breast:
        return jsonify({'error': 'The uploaded image is not a raw chicken breast. Please upload a valid image.'}), 400

    # Step 2: Proceed with the main algorithm
    with torch.no_grad():
        # Extract features using DeiT
        features = deit.forward_features(img_tensor)
        feature_vector = features.mean(dim=1).cpu().numpy()

    # Classify using SVM
    prediction = svm_model.predict(feature_vector)
    labels = ["Consumable", "Half-consumable", "Not consumable"]
    label = labels[int(prediction[0])]

    return jsonify({'prediction': label})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
