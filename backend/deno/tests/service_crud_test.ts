import { assertEquals } from "https://deno.land/std@0.181.0/testing/asserts.ts";

// Test 1 : GET /services/:id retourne le service demandé si existant
Deno.test("GET /services/:id - succès", async () => {
  const id = "service-id-existant";
  const res = await fetch(`http://localhost:8000/services/${id}`);
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 200);
  assertEquals(body.id, id);
});

// Test 2 : GET /services/:id retourne 404 si non trouvé
Deno.test("GET /services/:id - not found", async () => {
  const id = "id-inexistant-123";
  const res = await fetch(`http://localhost:8000/services/${id}`);
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 404);
  assertEquals(body.error, "Service non trouvé.");
});

// Test 3 : POST /services crée un service valide
Deno.test("POST /services - succès", async () => {
  const res = await fetch("http://localhost:8000/services", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      name: "Massage relaxant",
      professional_id: "pro-id-existant",
      price: 50,
      duration_minutes: 60,
      is_active: true
    })
  });
  const body = await res.json();
  console.log("Réponse:", res.status, body);
  assertEquals(res.status, 201);
  assertEquals(body.name, "Massage relaxant");
});

// Test 4 : POST /services avec nom vide retourne 400
Deno.test("POST /services - nom vide", async () => {
  const res = await fetch("http://localhost:8000/services", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      name: "",
      professional_id: "pro-id-existant",
      price: 50,
      duration_minutes: 60,
      is_active: true
    })
  });
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Le nom du service ne peut pas être vide.");
});

// Test 5 : POST /services avec professional_id inexistant retourne 400
Deno.test("POST /services - professional_id inexistant", async () => {
  const res = await fetch("http://localhost:8000/services", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      name: "Massage relaxant",
      professional_id: "pro-id-inexistant",
      price: 50,
      duration_minutes: 60,
      is_active: true
    })
  });
  const body = await res.json();
  console.log("Erreur attendue:", res.status, body);
  assertEquals(res.status, 400);
  assertEquals(body.error, "Le professionnel spécifié est introuvable.");
});
