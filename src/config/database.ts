import pg from 'pg';
import { ENV } from './env.js';
import logger from './logger.js';
import { error } from 'node:console';

const {Pool} = pg;

// Pool de conexiones — reutiliza conexiones en vez de abrir una nueva por petición
const pool = new Pool({
    host: ENV.DB.HOST,
    port: ENV.DB.PORT,
    database: ENV.DB.NAME,
    user: ENV.DB.USER,
    password: ENV.DB.PASSWORD,
    max:20,   // máximo de conexiones simultáneas
    idleTimeoutMillis: 30000, // cierra conexiones inactivas después de 30s
    connectionTimeoutMillis: 2000,
});

// Si la BD falla inesperadamente, lo registramos
pool.on('error', (err) =>{
    logger.error(`Error inesperado en el pool de PosgreSQL: ${error}`);
    process.exit(-1);
});

// Query simple — para tablas del schema public
export const query = (text:string, params?: unknown[]) =>
    pool.query(text, params);

// Query con tenant — cambia el search_path al schema de la empresa
export const tenantQuery = async (
    schemaName: string,
    text: string,
    params?: unknown[]
) =>{
    const client = await pool.connect();
    try {
        await client.query(`SET search_path TO ${schemaName}, public`);
        return await client.query(text, params);
    } finally {
        client.release();
    }
}

// Transacción con tenant — para operaciones que deben ser todo o nada
export const tenantTransaction = async (
    schemaName: string,
    callback: (client: pg.PoolClient) => Promise<void>
) =>{
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query(`SET search_path TO ${schemaName}, public`);
        await callback(client);
        await client.query('COMMIT');
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    }finally{
        client.release();
    }
};

export default pool;