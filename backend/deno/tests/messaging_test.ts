import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Création d'une conversation
Deno.test("Création d'une conversation unique entre deux utilisateurs", async () => {
  const convRes = await fetch("http://localhost:8000/conversations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ participants: ["user-msg-1", "user-msg-2"] })
  });
  const conv = await convRes.json();
  const convRes2 = await fetch("http://localhost:8000/conversations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ participants: ["user-msg-1", "user-msg-2"] })
  });
  const conv2 = await convRes2.json();
  console.log("Conversation unique:", conv, conv2);
  assertEquals(conv.id, conv2.id);
});

// Test 2 : Envoi d'un message et notification
Deno.test("Envoi d'un message et notification du destinataire", async () => {
  const convRes = await fetch("http://localhost:8000/conversations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ participants: ["user-msg-3", "user-msg-4"] })
  });
  const conv = await convRes.json();
  const msgRes = await fetch("http://localhost:8000/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ conversation_id: conv.id, sender_id: "user-msg-3", content: "Hello!" })
  });
  const msg = await msgRes.json();
  const notif = await (await fetch("http://localhost:8000/notifications?user_id=user-msg-4")).json();
  const foundNotif = notif.some((n: any) => n.type === "new_message" && n.message.includes("Hello!"));
  console.log("Message envoyé:", msg);
  console.log("Notification destinataire:", foundNotif, notif);
  assertEquals(msg.content, "Hello!");
  assertEquals(foundNotif, true);
});

// Test 3 : Pagination et consultation
Deno.test("Pagination des messages dans une conversation", async () => {
  const convRes = await fetch("http://localhost:8000/conversations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ participants: ["user-msg-5", "user-msg-6"] })
  });
  const conv = await convRes.json();
  // Envoi de 15 messages
  for (let i = 0; i < 15; i++) {
    await fetch("http://localhost:8000/messages", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ conversation_id: conv.id, sender_id: "user-msg-5", content: `Msg ${i}` })
    });
  }
  // Récupérer les 10 premiers
  const page1 = await (await fetch(`http://localhost:8000/messages?conversation_id=${conv.id}&limit=10&offset=0`)).json();
  // Récupérer les suivants
  const page2 = await (await fetch(`http://localhost:8000/messages?conversation_id=${conv.id}&limit=10&offset=10`)).json();
  console.log("Pagination page 1:", page1);
  console.log("Pagination page 2:", page2);
  assertEquals(page1.length, 10);
  assertEquals(page2.length, 5);
  assertEquals(page1[0].content, "Msg 0");
  assertEquals(page2[0].content, "Msg 10");
});

// Test 4 : Robustesse accès et suppression
Deno.test("Accès refusé et suppression logique", async () => {
  const convRes = await fetch("http://localhost:8000/conversations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ participants: ["user-msg-7", "user-msg-8"] })
  });
  const conv = await convRes.json();
  // Accès par un non participant
  const msgRes = await fetch(`http://localhost:8000/messages?conversation_id=${conv.id}&user_id=intrus`, {
    method: "GET"
  });
  const msgJson = await msgRes.json();
  // Suppression par un participant
  const delRes = await fetch(`http://localhost:8000/messages/${conv.id}?user_id=user-msg-7`, { method: "DELETE" });
  const delJson = await delRes.json();
  console.log("Accès non participant:", msgJson);
  console.log("Suppression logique:", delJson);
  assertEquals(msgJson.error !== undefined, true);
  assertEquals(delJson.deleted, true);
});
