// Base64 Encoder
export function toBase64Encoding(input: string): string {
  try {
    return btoa(input);
  } catch (error) {
    throw new Error("Failed to encode to Base64: Invalid input.");
  }
}

// Base64 Decoder
export function fromBase64Encoding(input: string): string {
  try {
    return atob(input);
  } catch (error) {
    console.log(error);

    throw new Error("Failed to decode Base64: Invalid input.");
  }
}

//   // Example Usage
//   const inputString = "Hello, Base64!";
//   const encoded = encodeToBase64(inputString);
//   console.log("Encoded:", encoded); // Encodes the string to Base64

//   const decoded = decodeFromBase64(encoded);
//   console.log("Decoded:", decoded); // Decodes it back to the original
