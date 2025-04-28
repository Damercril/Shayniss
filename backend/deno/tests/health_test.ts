import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1: GET /health doit retourner 200 et {status: "ok"}
Deno.test("GET /health retourne 200 et {status: 'ok'}", async () => {
  const response = await fetch("http://localhost:8000/health");
  const body = await response.json();
  console.log("Réponse:", response.status, body);
  assertEquals(response.status, 200);
  assertEquals(body.status, "ok");
});

// Test 2: GET route inconnue doit retourner 404
Deno.test("GET /unknown retourne 404", async () => {
  const response = await fetch("http://localhost:8000/unknown");
  console.log("Réponse:", response.status);
  assertEquals(response.status, 404);
});

// Chaque test vérifie la disponibilité et la robustesse du serveur.
