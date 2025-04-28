import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : GET /users/:id retourne l’utilisateur demandé si existant
Deno.test("GET /users/:id - succès", async () => {
  // Préparer un utilisateur existant (id à adapter selon votre jeu de données)
  const id = "user-id-existant";
  const res = await fetch(`http://localhost:8000/users/${id}`);
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 200);
  assertEquals(body.id, id);
});

// Test 2 : GET /users/:id retourne 404 si l’utilisateur n’existe pas
Deno.test("GET /users/:id - not found", async () => {
  const id = "id-inexistant-123";
  const res = await fetch(`http://localhost:8000/users/${id}`);
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 404);
  assertEquals(body.error, "Utilisateur non trouvé.");
});

// Test 3 : POST /users crée un utilisateur valide
Deno.test("POST /users - succès", async () => {
  const res = await fetch("http://localhost:8000/users", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "nouveluser@example.com",
      password: "motdepasse123",
      role: "client"
    })
  });
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.email, "nouveluser@example.com");
});

// Test 4 : POST /users avec email déjà existant retourne 400
Deno.test("POST /users - email déjà utilisé", async () => {
  const res = await fetch("http://localhost:8000/users", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      email: "nouveluser@example.com",
      password: "motdepasse123",
      role: "client"
    })
  });
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Cet email est déjà utilisé.");
});
