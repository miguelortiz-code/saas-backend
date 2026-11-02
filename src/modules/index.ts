import { Router } from 'express';
import authRoutes from './auth/auth.routes.js';

// Aquí se irán agregando los demás módulos a medida que se desarrollen
// import usersRoutes    from './users/users.routes.js';
// import productsRoutes from './products/products.routes.js';

const router = Router();

router.use('/auth', authRoutes);

export default router;