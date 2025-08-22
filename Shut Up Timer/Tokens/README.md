# Tokens Directory

This directory contains the design system tokens and assets that define the visual identity and theming of the Shut Up Timer app. These tokens provide a consistent foundation for colors, typography, spacing, and images across the entire application.

## 🏗️ Architecture

The tokens follow a centralized design system approach with:
- **Color Tokens**: Consistent color palette and theming
- **Font Tokens**: Typography system and font definitions
- **Image Assets**: Icon and image asset management
- **Design Consistency**: Unified visual language across the app

## 📁 Directory Structure

```
Tokens/
├── ColorTokens.swift     # Color palette and theme definitions
├── FontTokens.swift      # Typography system and font tokens
└── ImageAssets.swift     # Image and icon asset definitions
```

## 🎯 Design System Components

### Color Tokens (`ColorTokens.swift`)
Defines the app's color palette and theming system:

**Primary Colors:**
- **Accent Colors**: Primary brand colors and highlights
- **Background Colors**: App background and surface colors
- **Text Colors**: Text color hierarchy and contrast
- **Status Colors**: Success, warning, error, and info colors

**Theme Support:**
- **Light Theme**: Light mode color definitions
- **Dark Theme**: Dark mode color definitions
- **Dynamic Colors**: iOS dynamic color system integration
- **Accessibility**: High contrast and accessibility color variants

### Font Tokens (`FontTokens.swift`)
Typography system and font definitions:

**Font Hierarchy:**
- **Display Fonts**: Large, prominent text (headings, titles)
- **Body Fonts**: Regular text content
- **Caption Fonts**: Small, secondary text
- **Custom Fonts**: Special fonts like "ArchitectsDaughter-Regular"

**Typography Scale:**
- **Font Sizes**: Consistent size scale (xs, sm, md, lg, xl, xxl)
- **Font Weights**: Weight variations (light, regular, medium, bold)
- **Line Heights**: Proper line spacing for readability
- **Letter Spacing**: Character spacing adjustments

### Image Assets (`ImageAssets.swift`)
Centralized image and icon asset management:

**Asset Categories:**
- **Icons**: UI icons and interface elements
- **Illustrations**: App illustrations and graphics
- **Backgrounds**: Background images and patterns
- **Animations**: Animated assets and frames

**Asset Organization:**
- **Naming Convention**: Consistent asset naming scheme
- **Asset References**: Type-safe asset references
- **Image Loading**: Efficient image loading and caching
- **Asset Optimization**: Optimized image formats and sizes

## 🎨 Design System Features

### Consistent Theming
- **Unified Visual Language**: Consistent design across all screens
- **Brand Identity**: Strong brand recognition through consistent colors
- **Accessibility**: WCAG compliant color contrast ratios
- **Platform Integration**: Native iOS design system integration

### Responsive Design
- **Adaptive Layouts**: Support for different screen sizes
- **Dynamic Type**: Accessibility-friendly text scaling
- **Safe Areas**: Proper handling of device-specific safe areas
- **Orientation Support**: Landscape and portrait mode support

### Performance Optimization
- **Asset Optimization**: Compressed and optimized image assets
- **Lazy Loading**: Efficient asset loading strategies
- **Caching**: Asset caching for improved performance
- **Memory Management**: Proper memory usage for image assets

## 🔧 Flutter Migration Notes

### Design System Mapping
- **Color Tokens** → **Theme Data**: Convert color tokens to Flutter ThemeData
- **Font Tokens** → **Text Theme**: Convert font tokens to Flutter TextTheme
- **Image Assets** → **Asset References**: Use Flutter asset references
- **Dynamic Colors** → **Theme Mode**: Implement light/dark theme switching

### Key Considerations

#### Theme Implementation
1. **ThemeData**: Create comprehensive ThemeData for the app
2. **Color Scheme**: Define ColorScheme for consistent color usage
3. **Text Theme**: Implement TextTheme for typography
4. **Custom Themes**: Create custom theme extensions for app-specific tokens

#### Asset Management
1. **pubspec.yaml**: Declare assets in pubspec.yaml
2. **Asset References**: Use proper asset reference patterns
3. **Image Optimization**: Optimize images for Flutter
4. **Asset Preloading**: Preload critical assets for better performance

#### Responsive Design
1. **Media Queries**: Use MediaQuery for responsive layouts
2. **Flexible Widgets**: Use Flexible and Expanded for adaptive layouts
3. **Orientation Handling**: Handle orientation changes properly
4. **Safe Areas**: Use SafeArea for proper safe area handling

### Recommended Flutter Structure
```dart
// Example Flutter theme structure
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: ColorTokens.primaryColor,
      secondary: ColorTokens.accentColor,
      // ... other colors
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        fontSize: FontTokens.headline1Size,
        fontWeight: FontTokens.headline1Weight,
        fontFamily: FontTokens.primaryFont,
      ),
      // ... other text styles
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    // Dark theme configuration
  );
}
```

## 🚀 Development Guidelines

### Design System Usage
1. **Token Consistency**: Always use design tokens instead of hardcoded values
2. **Theme Integration**: Integrate with Flutter's theme system
3. **Accessibility**: Ensure accessibility compliance
4. **Performance**: Optimize assets and theme usage

### Asset Management
- **Naming Convention**: Follow consistent asset naming
- **Asset Optimization**: Compress and optimize all assets
- **Asset Organization**: Organize assets by category and purpose
- **Asset Documentation**: Document asset usage and purpose

### Theme Development
- **Color Palette**: Maintain consistent color palette
- **Typography Scale**: Use consistent typography scale
- **Spacing System**: Implement consistent spacing system
- **Component Library**: Create reusable component library

## 📱 Platform Considerations

### iOS-Specific Features
- **Dynamic Colors**: iOS dynamic color system
- **SF Symbols**: Native iOS icon system
- **System Fonts**: iOS system font integration
- **Dark Mode**: Native iOS dark mode support

### Cross-Platform Migration
- **Material Design**: Follow Material Design principles for Android
- **Cupertino Design**: Follow Cupertino design for iOS
- **Adaptive Design**: Create adaptive designs for both platforms
- **Platform Assets**: Use platform-specific assets when needed

### Asset Optimization
- **Vector Graphics**: Use vector graphics for scalability
- **Image Formats**: Use appropriate image formats (PNG, WebP, SVG)
- **Asset Sizing**: Provide appropriate asset sizes for different densities
- **Compression**: Compress assets for better performance

## 🔧 Testing

### Design System Testing
- **Visual Regression**: Test for visual consistency
- **Accessibility Testing**: Test accessibility compliance
- **Theme Testing**: Test theme switching and consistency
- **Asset Testing**: Test asset loading and display

### Performance Testing
- **Asset Loading**: Test asset loading performance
- **Memory Usage**: Test memory usage with assets
- **Theme Performance**: Test theme switching performance
- **Rendering Performance**: Test UI rendering performance

---

**Note**: When migrating to Flutter, focus on maintaining the same visual identity and design consistency while adapting to Flutter's theming system. Pay special attention to asset optimization and cross-platform design considerations.
