# Aplicaciones de Backend y Frontend de Alta Disponibilidad

Este proyecto contiene aplicaciones de backend y frontend diseñadas para ser desplegadas en un clúster de Kubernetes.

## Descripción

### Backend

El backend es una API simple construida con Express.js que expone un endpoint `/products` para obtener una lista de productos.

- Archivo principal: [`/backend/src/server.js`](/backend/src/server.js)
- Dockerfile: [`backend/Dockerfile`](/backend/Dockerfile)
- Dependencias: [`backend/package.json`](/backend/package.json)

### Frontend

El frontend es una aplicación web simple que sirve contenido estático utilizando Express.js.

- Archivo principal: [`frontend/src/server.js`](/frontend/src/server.js)
- Archivos estáticos: [`frontend/src/public/`](/frontend/src/public/)
- Dockerfile: [`frontend/Dockerfile`](/frontend/Dockerfile)
- Dependencias: [`frontend/package.json`](/frontend/package.json)

## Despliegue

### Construcción de Imágenes Docker

Para construir y subir las imágenes Docker del frontend y backend, ejecuta el script [`build_and_push.sh`](/scripts/build_and_push.sh):

```sh
./scripts/build_and_push.sh
```

Este script:

1. Construye las imágenes Docker para el frontend y backend.
2. Etiqueta las imágenes Docker con tu nombre de usuario de Docker Hub.
3. Sube las imágenes Docker a Docker Hub.

### Archivos de Kubernetes

Los manifiestos de Kubernetes se encuentran en el directorio [`k8s/`](/k8s/):

- Despliegue del backend: [`k8s/backend-deployment.yaml`](/k8s/backend-deployment.yaml)
- Servicio del backend: [`k8s/backend-service.yaml`](/k8s/backend-service.yaml)
- Despliegue del frontend: [`k8s/frontend-deployment.yaml`](/k8s/frontend-deployment.yaml)
- Servicio del frontend: [`k8s/frontend-service.yaml`](/k8s/frontend-service.yaml)

### Despliegue en Kubernetes

1. **Ejecuta el script de despliegue:**

   ```sh
   ./scripts/deploy_to_k8s.sh
   ```

2. **Verifica el estado de los pods y servicios:**

   ```sh
   kubectl get pods -n $NAMESPACE
   kubectl get svc -n $NAMESPACE
   ```

3. **Verifica los servicios:**

   ```sh
   ./scripts/check_services.sh
   ```

### Acceso a los Servicios

#### Backend

Para acceder al servicio backend, usa `kubectl port-forward`:

```sh
kubectl port-forward service/backend-service 4000:4000 -n $NAMESPACE
```

Luego, puedes acceder al endpoint `/products`:

```sh
curl http://localhost:4000/products
```

#### Frontend

El servicio frontend está expuesto como un `NodePort`. Puedes acceder a él usando la IP del nodo y el puerto especificado (30001 en este caso).

Si estás usando Minikube, obtén la IP de Minikube:

```sh
minikube ip
```

Luego, accede al servicio frontend:

```sh
curl http://$(minikube ip):30001
```

## Desarrollo Local

### Backend

Para iniciar el servidor backend localmente:

```sh
cd backend
npm install
npm run dev
```

El servidor backend estará disponible en `http://localhost:4000`.

### Frontend

Para iniciar el servidor frontend localmente:

```sh
cd frontend
npm install
npm run dev
```

El servidor frontend estará disponible en `http://localhost:3000`.
