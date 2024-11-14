# Daily Grocery 🛒

![photo_2024-11-14_12-30-38](https://github.com/user-attachments/assets/c4e520ec-ec62-4b7c-9645-27001adbf17e)


A full-stack e-commerce application for daily grocery shopping, built with Flutter and Django. Shop smarter, not harder!

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Django](https://img.shields.io/badge/Django-4.0+-092E20?style=for-the-badge&logo=django&logoColor=white)](https://www.djangoproject.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13.0+-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

## 📱 App Screenshots

![photo_2024-11-14_12-30-38](https://github.com/user-attachments/assets/f0d9fef3-b292-4e24-9c0d-98e32781ce8d)
![photo_2024-11-14_12-30-35](https://github.com/user-attachments/assets/85233779-0a86-488c-9fbb-d2ac1953ca4c)
![photo_2024-11-14_12-30-32](https://github.com/user-attachments/assets/9428fbe6-8466-4f06-b11e-1d96ce8aadf1)


## ✨ Features

- 🔐 User authentication and profile management
- 🏪 Browse products by categories
- 🔍 Advanced search functionality
- 🛒 Shopping cart management
- 💳 Secure payment integration
- 📦 Order tracking
- ⭐ Product reviews and ratings
- 📱 Cross-platform compatibility
- 🌙 Dark mode support
- 📍 Location-based store finder
- 🔔 Push notifications
- 💾 Offline support

## 🏗️ Project Structure

```
ecommerce/
├── backend/
│   ├── ...   
│
└── frontend/
    ├── ...
```

## 🛠️ Technology Stack

### Backend
- **Framework**: Django 4.0+
- **Database**: PostgreSQL 13.0+
- **Authentication**: JWT
- **Hosting**: PythonAnywhere
- **API**: Django REST Framework
- **Payment**: Stripe Integration
- **Storage**: AWS S3 (for media files)

### Frontend
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: Hive
- **Network**: Dio
- **Maps**: Google Maps Flutter
- **Notifications**: Firebase Cloud Messaging

## 🚀 Live Demo

- App: [Download from Play Store]([https://play.google.com/store/apps/details?id=com.yourdomain.dailygrocery](https://play.google.com/store/apps/details?id=daily.grocery.com.dailygrocery&pli=1))

## 📱 Deployment

### Backend Deployment (PythonAnywhere)

1. Create a PythonAnywhere account
2. Set up a new web app
3. Configure PostgreSQL database
4. Upload your code using Git
5. Set up virtual environment
6. Configure WSGI file
7. Set environment variables
8. Collect static files
9. Update allowed hosts

### Frontend Deployment

1. Build release APK:
```bash
flutter build apk --release
```

2. Build iOS app:
```bash
flutter build ios --release
```

## 🔑 API Endpoints

| Endpoint | Method | Description |
|----------|---------|-------------|
| `/api/auth/register/` | POST | User registration |
| `/api/auth/login/` | POST | User login |
| `/api/products/` | GET | List all products |
| `/api/products/<id>/` | GET | Product details |
| `/api/cart/` | GET, POST | Cart management |
| `/api/orders/` | GET, POST | Order management |

## 🧪 Testing

### Backend Tests
```bash
python manage.py test
```

### Frontend Tests
```bash
flutter test
```

## 📈 Performance Optimizations

- Image caching and compression
- Lazy loading of products
- API response caching
- Indexed database queries
- Efficient state management
- Optimized Flutter widgets

## 🔒 Security Features

- JWT Authentication
- CSRF Protection
- SQL Injection Prevention
- Input Validation
- Secure File Upload
- Rate Limiting
- SSL/TLS Encryption

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgments

- Flutter and Django communities
- All third-party package maintainers
- Contributors and testers
- Design inspiration from various grocery apps

## 📞 Support

For support:
- 📧 Email: support@dailygrocery.com
- 💬 Discord: [Join our server](https://discord.gg/dailygrocery)
- 📱 In-app support chat

---

Made with ❤️ by Kamlesh Kasambe for my Client (Freelance Project)

[⬆ Back to top](#daily-grocery-)
