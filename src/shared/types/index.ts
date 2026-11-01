import  {Request} from 'express';

// Usuario autenticado extraído del JWT
export interface AuthUser {
    id: number;
    uuid: string;
    email: string;
    role: string;
    schemaName: string;  // schema del tenant: "tenant_ferreteria_lopez"
    companyId: number;
}

// Request de Express extendido con usuario y tenant
export interface AuthRequest extends Request{
    user?: AuthUser;
    schemaName?: string;
}

// Estructura estándar de todas las respuestas de la API
export interface ApiResponse<T = unknown> {
    success: boolean;
    message: string;
    data?: T;
    errors?: string[];
    pagination?: Pagination; 
}

// Datos de paginación incluidos en respuestas de listas
export interface Pagination {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
}

// Parámetros calculados para hacer queries paginadas
export interface PaginationParams {
    page: number;
    limit: number;
    offset: number;
}