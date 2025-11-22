import { Injectable } from '@angular/core';
import Tesseract from 'tesseract.js';

export interface OCRResult {
  text: string;
  confidence: number;
  error?: string;
}

@Injectable({
  providedIn: 'root'
})
export class OcrService {
  
  constructor() { }

  /**
   * Extraer texto de una imagen usando Tesseract.js
   * @param imageFile Archivo de imagen o Data URL
   * @param language Idioma para OCR (default: 'spa' para español)
   */
  async extractTextFromImage(imageFile: File | string, language: string = 'spa+eng'): Promise<OCRResult> {
    try {
      console.log('🔍 Iniciando OCR...');
      
      // Convertir File a Image si es necesario
      let imageSource: string | File = imageFile;
      
      if (typeof imageFile === 'string') {
        imageSource = imageFile;
      }

      // Ejecutar OCR con Tesseract.js
      const result = await Tesseract.recognize(
        imageSource,
        language,
        {
          logger: (m) => {
            // Log de progreso
            if (m.status === 'recognizing text') {
              console.log(`📊 Progreso OCR: ${Math.round(m.progress * 100)}%`);
            }
          }
        }
      );

      console.log('✅ OCR completado');
      console.log('📝 Texto extraído:', result.data.text);
      console.log('🎯 Confianza:', result.data.confidence);

      return {
        text: result.data.text.trim(),
        confidence: result.data.confidence
      };

    } catch (error) {
      console.error('❌ Error en OCR:', error);
      return {
        text: '',
        confidence: 0,
        error: (error as Error).message
      };
    }
  }

  /**
   * Limpiar y formatear el texto extraído
   */
  formatExtractedText(text: string): string {
    return text
      .replace(/\s+/g, ' ') // Múltiples espacios a uno solo
      .replace(/\n\s*\n/g, '\n') // Múltiples líneas vacías a una
      .trim();
  }

  /**
   * Extraer valores de exámenes del texto (detectar patrones comunes)
   */
  extractExamValues(text: string): { campo: string; valor: string }[] {
    const values: { campo: string; valor: string }[] = [];
    
    // Patrón: "Campo: Valor unidad"
    const pattern1 = /([A-Za-záéíóúñÁÉÍÓÚÑ\s]+):\s*([0-9.,]+\s*[A-Za-z/]+)/gi;
    let match;
    while ((match = pattern1.exec(text)) !== null) {
      if (match[1] && match[2]) {
        values.push({
          campo: match[1].trim(),
          valor: match[2].trim()
        });
      }
    }
    
    // Patrón: "Campo Valor"
    const pattern2 = /([A-Za-záéíóúñÁÉÍÓÚÑ\s]{3,})[\s:]+([0-9.,]+)/gi;
    while ((match = pattern2.exec(text)) !== null) {
      if (match[1] && match[2]) {
        values.push({
          campo: match[1].trim(),
          valor: match[2].trim()
        });
      }
    }

    return values;
  }
}
