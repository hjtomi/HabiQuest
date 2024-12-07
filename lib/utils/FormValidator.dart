String? validateForm(
    String? email, String? password, String? rePassword, String? username) {
  if (email == null || email.isEmpty) {
    return 'Email cannot be empty';
  }
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(email)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password cannot be empty';
  }
  if (password.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}
