// Import the Genkit core libraries and plugins.
import { genkit, z } from "genkit";
import { vertexAI } from "@genkit-ai/vertexai";

// Import models from the Vertex AI plugin.
import { gemini15Flash } from "@genkit-ai/vertexai";

// Import Firebase Cloud Functions for Genkit.
import { onCallGenkit } from "firebase-functions/https";

// Import Firebase Secret Manager for API keys.
import { defineSecret } from "firebase-functions/params";
const apiKey = defineSecret("GOOGLE_GENAI_API_KEY");

const ai = genkit({
  plugins: [
    vertexAI({ location: "us-central1" }),
  ],
});

// Define a simple flow for menu suggestions.
const menuSuggestionFlow = ai.defineFlow({
  name: "menuSuggestionFlow",
  inputSchema: z.string().describe("A restaurant theme").default("seafood"),
  outputSchema: z.string(),
  streamSchema: z.string(),
}, async (subject: string, { sendChunk }: { sendChunk: (data: string) => void }) => {
  // Construct a request and send it to the model API.
  const prompt = `Suggest an item for the menu of a ${subject} themed restaurant`;
  const { response, stream } = ai.generateStream({
    model: gemini15Flash,
    prompt,
    config: { temperature: 1 },
  });

  for await (const chunk of stream) {
    sendChunk(chunk.text);
  }

  return (await response).text;
});

export const menuSuggestion = onCallGenkit({
  // Uncomment to enable AppCheck (for security).
  // enforceAppCheck: true,

  // Uncomment to enforce authentication (if needed).
  // authPolicy: hasClaim("email_verified"),

  // Grant access to the API key:
  secrets: [apiKey],
}, menuSuggestionFlow);
