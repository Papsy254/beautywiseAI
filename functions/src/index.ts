import * as functions from "firebase-functions/v2/https";
import express from "express";
import multer from "multer";
import * as logger from "firebase-functions/logger";
import axios from "axios";

// ✅ Use environment variable for the Google Access Token (better security)
const GOOGLE_ACCESS_TOKEN = process.env.GOOGLE_ACCESS_TOKEN; 

// ✅ Setup Express app and Multer for file upload
const app = express();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith("image/")) {
      return cb(new Error("File is not an image"));
    }
    cb(null, true);
  },
});

// ✅ Vertex AI Model Endpoint
const MODEL_ENDPOINT =
  "https://us-central1-aiplatform.googleapis.com/v1/projects/beautywise-ai/locations/us-central1/endpoints/6190555029099773952:predict";

// ✅ Handle image upload and prediction
app.post("/", upload.single("image"), async (req, res) => {
  logger.info("📸 Received a request for skin type prediction.", req.body);

  try {
    if (!req.file) {
      logger.warn("⚠️ No image uploaded.");
      return res.status(400).json({ error: "No image uploaded" });
    }

    logger.info("✅ File received: " + req.file.originalname);
    logger.info("🖼️ Converting image to Base64...");

    // ✅ Convert image to Base64
    const imageBase64 = req.file.buffer.toString("base64");

    // ✅ Send request to Vertex AI
    logger.info("🚀 Sending image to Vertex AI for prediction...");
    const response = await axios.post(
      MODEL_ENDPOINT,
      { instances: [{ image: { b64: imageBase64 } }] },
      {
        headers: {
          Authorization: `Bearer ${GOOGLE_ACCESS_TOKEN}`,
          "Content-Type": "application/json",
        },
        timeout: 30000,
      }
    );

    logger.info("✅ Vertex AI response received.");
    
    // ✅ Extract Prediction
    const prediction = response.data.predictions[0];
    const labels = ["Oily Skin", "Normal Skin", "Dry Skin", "Sensitive Skin"];
    const skinType = labels[prediction.indexOf(Math.max(...prediction))];

    logger.info(`🎯 Predicted Skin Type: ${skinType}`);
    return res.status(200).json({ skinType });

  } catch (error) {
    logger.error("❌ Error processing image:", error);
    return res.status(500).json({ error: "Failed to process image" });  }
});

// ✅ Root Route for Testing
app.get("/", (req, res) => {
  res.status(200).send("🔥 BeautyWise AI Skin Type Prediction API is running!");
});

// ✅ Export Firebase Function
export const predictSkinType = functions.onRequest(app);
