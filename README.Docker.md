### Building and running your application

When you're ready, start your application by running:
`docker compose up --build`.

Your application will be available at http://localhost:8080.

### Deploying your application to the cloud

First, build your image, e.g.: `docker build -t myapp .`.
If your cloud uses a different CPU architecture than your development
machine (e.g., you are on a Mac M1 and your cloud provider is amd64),
you'll want to build the image for that platform, e.g.:
`docker build --platform=linux/amd64 -t myapp .`.

Then, push it to your registry, e.g. `docker push myregistry.com/myapp`.

Consult Docker's [getting started](https://docs.docker.com/go/get-started-sharing/)
docs for more detail on building and pushing.

name: Build, Test, Scan, and Push Docker Image

on:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'maven'

      - name: Cache Maven packages
        uses: actions/cache@v3
        with:
          path: ~/.m2
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
          restore-keys: ${{ runner.os }}-m2

      - name: Build and test with Maven
        run: mvn -B package -Dtest=!PostgresIntegrationTests --file pom.xml

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build Docker image
        run: docker build . -t ${{ secrets.DOCKERHUB_USERNAME }}/spring-petclinic:latest

      # Add caching for Trivy database to avoid rate-limiting
      - name: Cache Trivy DB
        uses: actions/cache@v3
        with:
          path: ~/.cache/trivy
          key: ${{ runner.os }}-trivy-db
          restore-keys: ${{ runner.os }}-trivy-db

      - name: Run Trivy vulnerability scanner
        id: trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '${{ secrets.DOCKERHUB_USERNAME }}/spring-petclinic:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
          cache-dir: '~/.cache/trivy'  # Use cached Trivy DB

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3  # Updated to v3 as v2 is deprecated
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Check for critical vulnerabilities
        run: |
          if grep -q '"level": "CRITICAL"' trivy-results.sarif; then
            echo "Critical vulnerabilities found. Please review the scan results."
            exit 1
          else
            echo "No critical vulnerabilities found."
          fi

      - name: Push Docker image to Docker Hub
        run: docker push ${{ secrets.DOCKERHUB_USERNAME }}/spring-petclinic:latest

      - name: Upload test reports
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: surefire-reports
          path: target/surefire-reports

kubectl create secret docker-registry springkey \
--docker-server=https://index.docker.io/v1/ \
--docker-username=luniemma \
--docker-password=African2022! \
--docker-email=luniyisiemmanuel@gmail.com
