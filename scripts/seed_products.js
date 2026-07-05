const { execFileSync } = require('child_process');

const projectId = 'flutter-ecommerce-app-20260704';

const products = [
  {
    id: 'linen-shirt',
    name: 'Linen Shirt',
    description:
      'A breathable everyday linen shirt with a relaxed fit and soft washed texture.',
    price: 1899,
    imageUrl:
      'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=900&q=80',
    category: 'Apparel',
    stock: 18,
  },
  {
    id: 'canvas-sneakers',
    name: 'Canvas Sneakers',
    description:
      'Lightweight canvas sneakers with cushioned insoles for daily city wear.',
    price: 2499,
    imageUrl:
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80',
    category: 'Footwear',
    stock: 12,
  },
  {
    id: 'ceramic-mug',
    name: 'Ceramic Mug',
    description:
      'Hand-glazed ceramic mug with a generous handle and a satin finish.',
    price: 699,
    imageUrl:
      'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=900&q=80',
    category: 'Home',
    stock: 30,
  },
  {
    id: 'leather-wallet',
    name: 'Leather Wallet',
    description:
      'Slim full-grain leather wallet with six card slots and a cash sleeve.',
    price: 1299,
    imageUrl:
      'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=900&q=80',
    category: 'Accessories',
    stock: 22,
  },
  {
    id: 'desk-lamp',
    name: 'Desk Lamp',
    description:
      'Adjustable matte desk lamp with warm LED lighting for focused work.',
    price: 3299,
    imageUrl:
      'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=80',
    category: 'Home',
    stock: 9,
  },
  {
    id: 'cotton-tote',
    name: 'Cotton Tote',
    description:
      'Durable cotton tote bag with reinforced straps and a roomy main compartment.',
    price: 899,
    imageUrl:
      'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=900&q=80',
    category: 'Bags',
    stock: 25,
  },
  {
    id: 'wireless-headphones',
    name: 'Wireless Headphones',
    description:
      'Over-ear wireless headphones with balanced audio and long battery life.',
    price: 4999,
    imageUrl:
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
    category: 'Electronics',
    stock: 14,
  },
  {
    id: 'minimal-watch',
    name: 'Minimal Watch',
    description:
      'A clean analog watch with a brushed case and comfortable leather strap.',
    price: 3599,
    imageUrl:
      'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=900&q=80',
    category: 'Accessories',
    stock: 11,
  },
];

function firestoreValue(value) {
  if (typeof value === 'string') {
    return { stringValue: value };
  }
  if (typeof value === 'number') {
    return Number.isInteger(value) ? { integerValue: value } : { doubleValue: value };
  }
  throw new Error(`Unsupported value type: ${typeof value}`);
}

function firestoreDocument(product) {
  return {
    fields: Object.fromEntries(
      Object.entries(product).map(([key, value]) => [key, firestoreValue(value)]),
    ),
  };
}

async function main() {
  const login = JSON.parse(
    execFileSync('firebase', ['login:list', '--json'], { encoding: 'utf8' }),
  );
  const token = login.result[0]?.tokens?.access_token;
  if (!token) {
    throw new Error('Firebase CLI is not logged in.');
  }

  for (const product of products) {
    const url =
      `https://firestore.googleapis.com/v1/projects/${projectId}` +
      `/databases/(default)/documents/products/${product.id}`;
    const response = await fetch(url, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(firestoreDocument(product)),
    });

    if (!response.ok) {
      throw new Error(`${product.id}: ${response.status} ${await response.text()}`);
    }

    console.log(`Seeded ${product.name}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
