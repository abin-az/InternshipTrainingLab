// test-client.mjs
// Test script for OmniRoute AI Gateway

async function main() {
  const url = "http://localhost:20128/v1/chat/completions";
  
  const payload = {
    model: "auto",
    messages: [
      { role: "system", content: "You are a helpful and concise assistant." },
      { role: "user", content: "Say hello in 5 words." }
    ],
    temperature: 0.7
  };

  console.log("Sending request to OmniRoute gateway at:", url);
  console.log("Payload:", JSON.stringify(payload, null, 2));

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      console.error(`HTTP error! status: ${res.status} ${res.statusText}`);
      const text = await res.text();
      console.error("Response body:", text);
      return;
    }

    const data = await res.json();
    console.log("\n--- OmniRoute Response ---");
    console.log("Model used:", data.model || "auto");
    console.log("Content:\n", data.choices?.[0]?.message?.content || JSON.stringify(data, null, 2));
    if (data.usage) {
      console.log("\nToken Usage:", data.usage);
    }
  } catch (err) {
    console.error("Error connecting to OmniRoute:", err.message);
  }
}

main();
