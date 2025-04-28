import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : Inscription valide retourne 201 et un user
Deno.test("POST /auth/register - succès", async () => {
  const res = await fetch("http://localhost:8000/auth/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "testuser@example.com",
      password: "motdepasse123",
      role: "client"
    })
  });
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.email, "testuser@example.com");
  assertEquals(body.role, "client");
});

// Test 2 : Email déjà utilisé -> 400 avec message explicite
Deno.test("POST /auth/register - email déjà utilisé", async () => {
  const res = await fetch("http://localhost:8000/auth/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "testuser@example.com",
      password: "motdepasse123",
      role: "client"
    })
  });
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Cet email est déjà utilisé.");
});

// Test 3 : Mot de passe trop court -> 400 avec message explicite
Deno.test("POST /auth/register - mot de passe trop court", async () => {
  const res = await fetch("http://localhost:8000/auth/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "nouveluser@example.com",
      password: "123",
      role: "client"
    })
  });
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Le mot de passe doit contenir au moins 8 caractères.");
});
