import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : GET /professionals/:id retourne le professionnel demandé si existant
Deno.test("GET /professionals/:id - succès", async () => {
  // Préparer un professionnel existant (id à adapter selon votre jeu de données)
  const id = "pro-id-existant";
  const res = await fetch(`http://localhost:8000/professionals/${id}`);
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 200);
  assertEquals(body.id, id);
});

// Test 2 : GET /professionals/:id retourne 404 si non trouvé
Deno.test("GET /professionals/:id - not found", async () => {
  const id = "id-inexistant-123";
  const res = await fetch(`http://localhost:8000/professionals/${id}`);
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 404);
  assertEquals(body.error, "Professionnel non trouvé.");
});

// Test 3 : POST /professionals crée un professionnel valide
Deno.test("POST /professionals - succès", async () => {
  const res = await fetch("http://localhost:8000/professionals", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      user_id: "user-id-existant",
      display_name: "Pro Test",
      category_id: "cat-id-existant",
      is_active: true
    })
  });
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.display_name, "Pro Test");
});

// Test 4 : POST /professionals avec user_id déjà lié retourne 400
Deno.test("POST /professionals - user_id déjà lié", async () => {
  const res = await fetch("http://localhost:8000/professionals", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      user_id: "user-id-existant",
      display_name: "Pro Test",
      category_id: "cat-id-existant",
      is_active: true
    })
  });
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Un professionnel existe déjà pour cet utilisateur.");
});
