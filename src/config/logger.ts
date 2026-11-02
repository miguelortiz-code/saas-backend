import winston  from 'winston';
import { ENV } from './env.js';

const {combine, timestamp, colorize, printf, json} = winston .format;

// Formato legible para desarrollo
const devFormat = printf(({level, message, timestamp}) =>
    `${timestamp} [${level}]: ${message}`
);
// Logger principal — maneja consola y archivos según el entorno
const logger = winston.createLogger({
    level: ENV.IS_PROD ? 'info' : 'debug',
    transports: [
        // Consola con colores (solo desarrollo)
        new winston.transports.Console({
            format: combine(
                colorize (),
                timestamp({format: 'HH:mm:ss'}),
                devFormat
            ),
        }),

        // Archivo solo para errores
        new winston.transports.File({
            filename: 'logs/error.log',
            level: 'error',
            format: combine(timestamp(), json()),
        }),
        
        // Archivo con todos los logs
        new winston.transports.File({
            filename: 'logs/combined.log',
            format: combine(timestamp(), json()),
        }),
    ],
});

export default logger;