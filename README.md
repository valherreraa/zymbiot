# 🧫 Zymbiot

Zymbiot es una aplicación móvil desarrollada en **Flutter** que permite **digitalizar y automatizar el análisis microbiológico** de halos de lisis en placas Petri, optimizando la evaluación de la **eficiencia de fagos** mediante **visión por computadora** e **inteligencia artificial**.

---

## 🚀 Descripción general

Zymbiot facilita el análisis de halos de lisis a partir de imágenes tomadas o cargadas desde el dispositivo móvil.
La aplicación realiza la segmentación y detección de halos mediante un modelo entrenado en **Roboflow**, conectado a través de su **API REST**, generando resultados cuantitativos como **diámetro, área, perímetro y circularidad**, además de generar **reportes en PDF y Excel** con las imágenes analizadas y los datos obtenidos.

Zymbiot busca reducir la subjetividad y el tiempo en los procesos microbiológicos, contribuyendo a la **automatización y estandarización de la biotecnología experimental**.

---

## 🧩 Características principales

* Captura o carga de imágenes de placas Petri.
* Análisis automatizado mediante modelo de IA (Roboflow).
* Resultados detallados (ID, diámetro, área, perímetro y circularidad).
* Generación automática de reportes en **PDF y Excel (.xlsx)**.
* Almacenamiento seguro en Firebase.
* Registro e inicio de sesión de usuarios.
* Biblioteca de documentos generados.

---

## 🏗️ Arquitectura e infraestructura

Zymbiot se basa en una arquitectura **cliente-servidor**:

* **Cliente:** Aplicación móvil desarrollada en Flutter.
* **Servidor:** Servicios en la nube de Firebase (autenticación, base de datos y almacenamiento).
* **Procesamiento:** Modelo de segmentación alojado en Roboflow, consumido mediante API REST.

Esta infraestructura garantiza **escalabilidad, disponibilidad y seguridad** de los datos y análisis.

---

## ⚙️ Tecnologías utilizadas

| Área                    | Tecnología                         |
| ----------------------- | ---------------------------------- |
| Lenguaje y Framework    | Flutter / Dart                     |
| Inteligencia Artificial | Roboflow (YOLOv8 / Segmentación)   |
| Backend / Base de datos | Firebase                           |
| Autenticación           | Firebase Auth                      |
| Almacenamiento          | Firebase Storage                   |
| Reportes PDF y Excel    | ReportLab / openpyxl / pdf package |
| Control de versiones    | Git & GitHub                       |

---

## 🧠 Metodología de desarrollo

El desarrollo se realizó bajo la metodología ágil **Scrum**, organizada en tres etapas:

1. **Desarrollo del modelo de segmentación** de halos de lisis con visión por computadora y conexión con Roboflow.
2. **Implementación de funcionalidades** en Flutter: carga de imágenes, generación de reportes (PDF y Excel) y almacenamiento en la nube.
3. **Optimización de la interfaz y pruebas de usabilidad**, garantizando una experiencia intuitiva y eficiente para el usuario.

---

## 🔒 Aviso de privacidad

Zymbiot recopila datos personales básicos como **nombre, correo electrónico y credenciales de acceso** con el único fin de **gestionar la autenticación y el almacenamiento seguro de resultados**.
No se recopilan datos de ubicación ni se comparten datos personales con terceros, salvo los estrictamente necesarios para el funcionamiento de los servicios de Firebase y Roboflow, los cuales cumplen con políticas de seguridad y cifrado de datos.

---

## 🧭 Trabajo futuro

* Implementación de otras métricas avanzadas de análisis.
* Integración de modelos locales para análisis sin conexión.

---

## 👩‍💻 Autora

**Valeria Ceja Herrera**

Evaluación automatizada de la actividad lítica de bacteriófagos en placas Petri utilizando visión por computadora e inteligencia artificial.

---

