# AI Interior Design

> Imagine your home differently.

AI Interior Design is a mobile application that uses artificial intelligence to help users visualize a new interior design from a simple photo of their room.

The user can upload a photo of their interior, select the room type, choose a design style and select a preferred color. These parameters are then sent to the backend, where they are processed using artificial intelligence.

The application then displays the generated result. The user can also view an estimated price and access store websites where the furniture can be found or viewed.

---

## Features

* Take a photo of an interior
* Select an image from the device gallery
* Select the room type
* Select an interior design style
* Select a preferred color
* Generate a new interior design using artificial intelligence
* View the original and generated interior
* View an estimated price range of piece of furniture
* View stores or websites related to the furniture
* Open a store website directly from the application

---

## User Flow

The application follows a simple and intuitive process:

```text
Home
  |
  v
Add a Photo
  |
  v
Configuration
  |
  v
AI Generation
  |
  v
Generated Result
  |
  v
Suggested Furniture
  |
  v
Estimated Price and Stores
  |
  v
Store Website
```

---

## Application Pages

### main.dart

`main.dart` is the entry point of the Flutter application.

It is responsible for launching the application and defining the initial screen displayed to the user.

### HomePage

The `HomePage` is the main screen of the application.

It introduces the AI Interior Design concept and allows the user to start the experience.

### PhotoPage

The `PhotoPage` allows the user to add a photo of their interior.

The user can either take a new photo using the camera or select an existing image from the device gallery.

### ConfigurationPage

The `ConfigurationPage` allows the user to define the parameters of the desired transformation.

The user can select:

* Room type
* Interior design style
* Color

These parameters are then used during the AI generation process.

### GenerationPage

The `GenerationPage` is displayed while the AI processing is running.

It informs the user that the new interior design is being generated.

### ResultatPage

The `ResultatPage` displays the generated interior design.

The user can compare the original interior with the generated result and visualize the proposed transformation.

### MeubleGenerationPage

The `MeubleGenerationPage` presents the furniture suggested by the application.

It displays:

* Furniture name
* Furniture description
* Furniture image
* Estimated price
* Available stores or websites

The user can also access the website of a store directly from this page.

---

## Frontend and Backend Communication

The frontend is developed using Flutter and Dart.

The application communicates with the backend through HTTP requests.

When the user starts the generation process, the frontend sends the information required by the backend.

These data may include:

* The interior photo
* Room type
* Interior design style
* Selected color
* Furniture information

The backend receives these parameters and performs the required artificial intelligence processing.

After the processing is completed, the backend sends a response back to the frontend.

The frontend then processes this response and displays the appropriate information to the user.

The general communication flow is:

```text
User
 |
 | Selects photo and parameters
 v
Flutter Frontend
 |
 | HTTP Request
 v
Backend
 |
 | AI Processing
 v
Backend Response
 |
 | HTTP Response
 v
Flutter Frontend
 |
 v
Displayed Result
```

---

## HTTP Request

The frontend uses HTTP requests to communicate with the backend.

A `POST` request is used to send data to the server.

The request specifies that the data are sent in JSON format using the `Content-Type` header.

The required information is then included in the request body.

For example:


http.post(uri,
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'room_type': roomType,
    'style': style,
    'color': color,
    'furniture': furniture,
  }),
);


After sending the request, the frontend receives the backend response through the `response` variable.

The `response.statusCode` can be used to check whether the request was successful, while `response.body` contains the data returned by the backend.

During development, `debugPrint` is also used to display the response in the console for testing and debugging purposes.

 Estimated Furniture Price

The backend provides an estimated price range for the suggested furniture.

The frontend receives this information using:


final String? estimatedPrice;


The value is then processed and displayed on the furniture page.

The frontend does not calculate the furniture price.

The backend provides the estimated price, while the frontend is responsible for retrieving and displaying it to the user.


## Stores and Websites

The backend also provides a list of stores or websites related to the suggested furniture.

This information is received by the frontend using:


final List<dynamic> stores;


The frontend then iterates through the list and displays the available stores.

For each store, the application retrieves information such as the store name and website URL.

This allows the user to discover where the suggested furniture can be found or viewed.

---

## Opening Store Websites

The application uses the `url_launcher` package to open store websites.

When the user selects a store, the application uses `launchUrl` with the corresponding URL.


await launchUrl(
  uri,
  mode: LaunchMode.externalApplication,
);
```

The website is then opened directly in the user's browser.

This provides a simple way for the user to continue their search outside the application.

---

## Technologies

### Frontend

* Flutter
* Dart

### Main Packages

* `http`
* `url_launcher`
* `google_fonts`
* `gal`

These packages are used for different features such as HTTP communication, image handling, custom fonts, and opening external websites.

---

## Project Architecture

The application follows a frontend/backend architecture.

```text
                    Flutter Application
                            |
        -----------------------------------------
        |          |          |         |       |
     HomePage   PhotoPage  Config.   Result   Furniture
                              Page     Page      Page
                            |
                            |
                      HTTP Requests
                            |
                            v
                         Backend
                            |
                       AI Processing
                            |
                            v
                         Response
                            |
                            v
                    Flutter Application
                            |
                            v
                  Displayed to the User
```

---

## Project Structure

The main Flutter files are organized as follows:

```text
lib/
|
├── main.dart
|
├── home_page.dart
├── photo_page.dart
├── configuration_page.dart
├── generation_page.dart
├── resultat_page.dart
└── meuble_generation_page.dart
```

The exact project structure may vary depending on the final organization of the application.

---

## Installation

### Prerequisites

Before running the project, make sure the following tools are installed:

* Flutter
* Dart
* Android Studio
* An Android emulator or a physical Android device

To verify the Flutter installation:

```bash
flutter doctor
```

---

## Getting Started

Clone the repository:

```bash
git clone <REPOSITORY_URL>
```

Navigate to the project directory:

```bash
cd <PROJECT_NAME>
```

Install the project dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## Project Objective

The main objective of AI Interior Design is to make interior design exploration easier and more accessible.

Instead of manually imagining how a room could look after a transformation, the user can provide a photo and select a few preferences.

The artificial intelligence then generates a new interior design based on these parameters.

The application also provides a practical aspect by suggesting furniture related to the generated design, together with an estimated price and store websites.

---

## Frontend Contribution

The frontend development focuses on providing a complete and intuitive user experience.

The main responsibilities include:

* Designing the user interfaces
* Creating the different application pages
* Implementing navigation between pages
* Managing frontend data
* Handling images
* Communicating with the backend
* Displaying the generated result
* Displaying furniture information
* Displaying the estimated price
* Displaying stores and websites
* Opening external store websites

---

## Conclusion

AI Interior Design combines a Flutter mobile interface with an artificial intelligence backend to provide an interactive interior design experience.

The user can start with a simple photo, define their preferences, receive an AI-generated transformation, discover a suggested piece of furniture, view its estimated price, and access relevant store websites.

The application therefore connects the user's interior design preferences with an AI-powered generation process and practical information about the suggested furniture.
