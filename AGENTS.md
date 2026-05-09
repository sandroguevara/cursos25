# AGENTS.md

## Repositorio: cursos25_microservicios

Proyecto educativo de microservicios Spring Boot 2.2.x con Java 12/13. Arquitectura por capas con Eureka, Gateway y Feign.

## Estructura del Proyecto

```
cursos25_microservicios/
├── microservicios-eureka/          # Service Registry - puerto 8761
├── microservicios-gateway/          # API Gateway - puerto 8090
├── microservicios-usuarios/         # Alumnos
├── microservicios-cursos/           # Cursos (usa Feign para respuestas)
├── microservicios-examenes/         # Examenes
├── microservicios-respuestas/       # Respuestas
├── commons-microservicios/          # CommonController, CommonService (CRUD generico)
├── commons-alumnos/                 # Entidad Alumno compartida
└── commons-examenes/                # Entidades Examen, Pregunta, Asignatura
```

## Nomenclatura

- Paquetes Java: `com.formacionbdi.microservicios.app.{modulo}.{capa}`
- Paquetes comunes: `com.formacionbdi.microservicios.commons...`
- Nombres en espanol para entidades y endpoints
- Metodos CRUD: listar, ver, crear, editar, eliminar

## Tecnologias

- Spring Boot 2.2.x, Spring Cloud Hoxton, Java 12/13
- Eureka (service discovery), Spring Cloud Gateway (enrutamiento), OpenFeign (comunicacion)
- JPA/Hibernate con PagingAndSortingRepository y CrudRepository
- MySQL/MariaDB (ddl_auto=update, MariaDB103Dialect)
- Puertos dinamicos `${PORT:0}` para escalabilidad horizontal

## Patrones Clave

- Microservicios extienden `CommonController<T>` y `CommonService<T>` de commons-microservicios
- `RespuestaFeignClient` en cursos llama a microservicio-respuestas
- Gateway enruta `/api/alumnos/**` -> `lb://microservicio-usuarios` (StripPrefix=2)
- Entidades compartidas via dependencias Maven (no duplicacion)
- Asignatura con estructura jerarquica (self-referencing ManyToOne/OneToMany)
- Alumno con campo foto como `byte[] @Lob`

## Ejecutar / Build

- `mvnw.cmd clean install` en cada modulo o desde la raiz con `-pl`
- Cada microservicio es arrancable independently (Spring Boot app)
- Eureka en localhost:8761 debe estar corriendo primero
- Gateway en localhost:8090 enruta a servicios registrados

## Skills Disponibles

- `skills/ArquitecturaSpring.md` - Generador de proyectos Java/Spring con soporte para perfiles entrenables y generacion de microservicios.
- `skills/new-microservice-java25.md` - Generador de microservicios Java 25 + Spring Boot 4.0.6 listo para produccion con Eureka, OAuth2 y Docker.
- `skills/generate-arch-docs.md` - Generador de documentacion arquitectonica y diagramas Mermaid a partir del codigo fuente.

Skills provide specialized instructions and workflows for specific tasks. Use the skill tool to load a skill when a task matches its description.