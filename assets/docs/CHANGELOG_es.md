## 1.8.0 (14.07.2026)

- **Nuevo**: Entrada por voz – habla con naturalidad para agregar un gasto, con monto, descripción, categoría, fecha y quién pagó reconocidos automáticamente, en todos los idiomas admitidos
- **Nuevo**: Escaneo de recibos por OCR – fotografía un recibo y deja que el reconocimiento de texto en el dispositivo extraiga el monto y la descripción por ti
- **Nuevo**: Búsqueda de imágenes de Unsplash para los fondos de grupo, con descarga directa en la app
- **Nuevo**: Widget de Android para la pantalla de inicio que muestra el total gastado hoy y en el grupo, con acciones de agregado rápido y apertura de grupo
- **Nuevo**: Página de búsqueda de gastos dedicada con búsqueda de texto completo, calendario que resalta los días con gastos y filtros por categoría, participante, adjunto y ubicación
- **Nuevo**: Búsqueda de grupos a pantalla completa estilo Gmail desde la página de grupos
- **Nuevo**: Plantillas de grupo personalizadas – crea, edita y elimina tus propios tipos de grupo con nombre, icono y categorías predeterminadas desde Ajustes
- **Mejoras**: Página de detalle de grupo rediseñada para coincidir con el estilo de las tarjetas de inicio, con encabezado centrado
- **Mejoras**: Asistente de creación de grupo con diseño y campos de entrada más cuidados
- **Mejoras**: El editor de plantillas de grupo ahora se abre en una página dedicada a pantalla completa, con selección de icono más clara y lista de categorías editable, disponible también al editar un grupo existente
- **Correcciones**: La entrada por voz ya no deja un símbolo de moneda en la descripción y ahora informa correctamente los errores de reconocimiento en lugar de fallar en silencio
- **Correcciones**: El botón de escaneo de recibo abre la cámara directamente, con la galería disponible mediante pulsación larga
- **Correcciones**: El selector de fondos de Unsplash ya no muestra miniaturas desactualizadas y ahora funciona correctamente en todas las compilaciones de lanzamiento
- **Correcciones**: La verificación de nombres duplicados ya no marca el elemento en edición como duplicado de sí mismo
- **Correcciones**: El formulario de agregar gasto ya no muestra un fondo rojo "no válido" al abrirse, y el botón Agregar/Guardar se vuelve del color primario en cuanto el formulario es válido
- **Correcciones**: La hoja de agregar gasto rápido ahora se abre en modo de edición completa con un gesto de deslizar hacia arriba

## 1.6.0 (03.04.2026)

- **Nuevo**: Integración de agentes IA de Android – Google Gemini puede agregar gastos y verificar saldos por ti
- **Nuevo**: Asistente de creación de grupo con flujo guiado de 3 pasos
- **Nuevo**: Separadores mensuales en la lista de gastos para mejor navegación
- **Nuevo**: Paginación para listas de gastos grandes con carga fluida
- **Nuevo**: Tarjeta destacada en la pantalla principal para tu grupo fijado
- **Nuevo**: Animaciones suaves al agregar nuevos gastos
- **Mejoras**: Diseño de pantalla principal rediseñado con grupo destacado y carrusel
- **Mejoras**: Configuración de grupo reorganizada en páginas dedicadas para acceso más fácil
- **Mejoras**: Opciones de exportación mostradas en diseño de tarjetas claro
- **Mejoras**: Cargador esqueleto de la pantalla principal mejorado
- **Correcciones**: Los montos de gastos ahora muestran decimales correctamente en todos lados
- **Correcciones**: Las notificaciones persistentes respetan los rangos de fechas del grupo
- **Correcciones**: Las notificaciones se actualizan correctamente desde todos los puntos de acceso
- **Correcciones**: La página de bienvenida aparece suavemente en el primer inicio

## 1.4.0 (16.12.2025)

- **Nuevo**: Soporte de archivos adjuntos multimedia para gastos (imágenes, PDF, videos) con visor de pantalla completa
- **Nuevo**: Formato de exportación markdown con estadísticas completas y tablas de gastos
- **Nuevo**: Edición de grupo con pestañas organizadas para General, Participantes, Categorías y Configuración
- **Nuevo**: Botón compartir en formulario de gasto para compartir detalles como texto
- **Mejoras**: La cámara ahora se abre con la cámara trasera por defecto para fotos más naturales
- **Mejoras**: Manejo de archivos adjuntos mejorado con mejor retroalimentación de errores y estabilidad
- **Mejoras**: Configuración de grupo consolidada en una sola interfaz con navegación por pestañas
- **Correcciones**: Los iconos de notificación de Android ahora funcionan correctamente en todas las variantes de compilación
- **Correcciones**: Estilo de botones consistente en todos los formularios
- **Técnico**: Actualización a Flutter 3.38.3 con versiones de dependencias más recientes

## 1.2.0 (03.12.2025)

- **Nuevo**: Mapas interactivos con OpenStreetMap mostrando ubicaciones de gastos
- **Nuevo**: Búsqueda de ubicación con autocompletado y captura GPS automática
- **Nuevo**: Tema dinámico que se adapta al fondo de pantalla del dispositivo (Android 12+)
- **Nuevo**: Acciones rápidas de Android para iniciar grupos de gastos desde la pantalla de inicio
- **Nuevo**: Comprobación automática de actualizaciones con notificaciones semanales
- **Mejoras**: Animaciones de carga skeleton más fluidas
- **Mejoras**: Visualización de moneda mejorada con formato local
- **Correcciones**: La configuración de ubicación automática ahora se guarda correctamente

## 1.0.45 (16.10.2025)

- **Correcciones**: Completadas las traducciones para todos los idiomas compatibles
- **Correcciones**: Añadidas claves de traducción faltantes en español (3), portugués (81) y chino (135)
- **Mejoras**: Todos los idiomas ahora tienen paridad completa con 511 claves de traducción cada uno

## 1.0.44 (09.01.2025)

- **Cambios**: La aplicación de Android ahora está restringida solo a dispositivos smartphone (tabletas excluidas) para una experiencia de usuario óptima
- **Cambios**: Refactorización de las pruebas de lógica de habilitación del botón guardar para mejorar la legibilidad y coherencia

## 1.0.38 (07.01.2025)

- **Nuevo**: Página "Novedades" accesible desde el número de versión en configuración
- **Mejoras**: Interfaz de usuario optimizada para Material 3
- **Correcciones**: Correcciones menores para la estabilidad de la aplicación