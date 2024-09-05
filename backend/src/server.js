import express from 'express';
const app = express();
const port = 4000;

const products = [
    { productId: 1, title: "Title 01" },
    { productId: 2, title: "Title 02" }
];

app.get('/products', (req, res) => {
    res.json(products);
});

app.listen(port, () => {
    console.log(`Backend server running at http://localhost:${port}`);
});