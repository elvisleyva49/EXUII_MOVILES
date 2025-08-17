# Sistema de Gestión de Solicitudes Universitarias

## Descripción del Proyecto
El **Sistema de Gestión de Solicitudes Universitarias** es una aplicación móvil desarrollada en **Flutter** que permite la gestión digital de solicitudes académicas dentro de la universidad. Su propósito es automatizar los procesos de creación, revisión, aprobación y entrega de documentos académicos, garantizando trazabilidad, seguridad y eficiencia.

---

## Tecnologías Utilizadas
- **Lenguaje de Programación:** Dart  
- **Framework / SDK:** Flutter  
- **Gestor de Base de Datos:** Firebase Firestore  
- **Autenticación / Seguridad:** Firebase Authentication  
- **APIs / Servicios Externos:** Firebase (Auth, Firestore, Storage), PDF (generación y descarga de documentos)

---

## Instalación y Ejecución del APK
1. Descargar el archivo APK proporcionado.  
2. Instalar el APK en un dispositivo Android compatible (API 21+).  
3. Abrir la aplicación e iniciar sesión con las credenciales de prueba.

---

## Usuarios de Prueba

| Rol          | Usuario       | Contraseña |
|--------------|---------------|------------|
| Estudiante   | elvis@upt.pe  | 123456     |
| Secretaria   | sec@upt.pe    | 123456     |
| Decano       | dec@upt.pe    | 123456     |
| Dirección    | dir@upt.pe    | 123456     |

---

## Flujo de Trabajo de Solicitudes

### 1. Separación de Ciclo y Constancia de Estudios
El flujo de aprobación es similar para ambas solicitudes:

1. **Estudiante:** Inicia el trámite creando la solicitud.  
2. **Secretaria:** Revisa el documento y aprueba.  
3. **Decano:** Revisa el documento y aprueba.  
4. **Secretaria (Revisión Final):** Realiza una última verificación y aprueba.  
5. **Estudiante:** Recibe el documento aprobado y sellado de manera digital.

---

### 2. Validación de Prácticas Profesionales
El flujo de aprobación es más completo debido a la validación adicional requerida:

1. **Estudiante:** Inicia el trámite creando la solicitud.  
2. **Secretaria:** Revisa el documento y aprueba.  
3. **Decano:** Revisa el documento y aprueba.  
4. **Secretaria (Segunda Revisión):** Revisa nuevamente y aprueba.  
5. **Dirección:** Revisa el documento y aprueba.  
6. **Secretaria (Revisión Final):** Realiza la verificación final y aprueba.  
7. **Estudiante:** Recibe el documento aprobado y sellado de manera digital.

---

## Cómo Probar los Flujos
1. Iniciar sesión como **Estudiante** y crear cada tipo de solicitud.  
2. Iniciar sesión con los roles administrativos correspondientes (**Secretaria**, **Decano**, **Dirección**) para revisar y aprobar cada solicitud según el flujo definido.  
3. Verificar que el documento final llega al estudiante con la aprobación digital y el sello correspondiente.  
4. Para **Separación de Ciclo** y **Constancia de Estudios**, observar que el flujo termina con la última aprobación de la secretaria.  
5. Para **Validación de Prácticas Profesionales**, seguir el flujo extendido con todas las revisiones antes de la entrega final al estudiante.

---

## Contacto y Soporte
En caso de dudas o problemas al ejecutar el APK, contactarse con el equipo de desarrollo:  
- **Correo:** soporte@upt.pe  
- **Teléfono:** +51 123 456 789  

---

Este README permite a los evaluadores reproducir los flujos de prueba de forma precisa y entender la estructura de aprobación de cada tipo de solicitud académica.
