<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Account | Sail Lanka Safari" />
<jsp:include page="../layouts/header.jsp" />

<div class="auth-page-wrapper">
    <div class="card auth-card" style="width: 100%; max-width: 500px; box-shadow: 0 25px 60px rgba(0, 0, 0, 0.55), 0 0 35px rgba(212, 175, 55, 0.2); border: 1px solid rgba(212, 175, 55, 0.35); border-radius: 16px; overflow: hidden; background: rgba(255, 255, 255, 0.98); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); position: relative; z-index: 2;">
        <div class="card-header" style="text-align: center; display: block; padding: 28px 24px 16px 24px; background: #FFFFFF; border-bottom: 1px solid var(--border-color);">
            <div class="logo-symbol" style="margin: 0 auto 12px auto; width: 50px; height: 50px; font-size: 22px; box-shadow: 0 6px 20px rgba(212, 175, 55, 0.4);">
                <i class="fa-solid fa-user-plus"></i>
            </div>
            <h2 style="font-size: 24px; color: var(--navy-primary); font-weight: 700;">Join Sail Lanka</h2>
            <p style="font-size: 13.5px; color: var(--text-muted); margin-top: 4px;">Create your guest account to manage ocean cruise bookings</p>
        </div>

        <div class="card-body">
            <form action="${pageContext.request.contextPath}/register" method="POST">
                <input type="hidden" name="csrf_token" value="${csrfToken}">

                <div class="form-group">
                    <label class="form-label"><i class="fa-solid fa-user"></i> Full Name</label>
                    <input type="text" name="fullName" class="form-control" required placeholder="e.g. David Miller">
                </div>

                <div class="form-group">
                    <label class="form-label"><i class="fa-solid fa-envelope"></i> Email Address</label>
                    <input type="email" name="email" class="form-control" required placeholder="david.miller@gmail.com">
                </div>

                <div class="form-group" style="margin-bottom: 18px;">
                    <label class="form-label" for="phoneInput" style="font-weight: 600; font-size: 13.5px; display: block; margin-bottom: 6px;">
                        <i class="fa-solid fa-phone" style="color: var(--champagne-gold); margin-right: 6px;"></i> Phone Number
                        <span style="color: var(--danger);">*</span>
                    </label>
                    <div style="position: relative;">
                        <input type="tel" 
                               id="phoneInput" 
                               name="phone" 
                               class="form-control" 
                               required 
                               placeholder="+44 7911 123456" 
                               autocomplete="tel"
                               maxlength="22"
                               style="width: 100%; padding: 11px 40px 11px 14px; border: 1px solid var(--border-color); border-radius: 6px; font-size: 14px; transition: var(--transition);">
                        <span id="phoneStatusIcon" style="position: absolute; right: 12px; top: 50%; transform: translateY(-50%); font-size: 14px; display: none;"></span>
                    </div>
                    <div id="phoneErrorMsg" style="display: none; color: var(--danger); font-size: 12px; margin-top: 5px; font-weight: 500;">
                        <i class="fa-solid fa-circle-exclamation"></i> <span id="phoneErrorText">Letters are not allowed. Please enter digits only.</span>
                    </div>
                    <div id="phoneHelp" style="font-size: 11.5px; color: var(--text-muted); margin-top: 4px;">
                        Include country code if international (e.g., +44 7911 123456 or 0771234567). Digits only.
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label"><i class="fa-solid fa-globe"></i> Country of Origin</label>
                    <input type="text" name="country" class="form-control" value="Sri Lanka" placeholder="e.g. United Kingdom, Australia">
                </div>

                <div class="form-group">
                    <label class="form-label"><i class="fa-solid fa-lock"></i> Password</label>
                    <input type="password" name="password" class="form-control" required placeholder="At least 6 characters">
                </div>

                <button type="submit" class="btn btn-gold" style="width: 100%; margin-top: 10px;">
                    <i class="fa-solid fa-circle-check"></i> Register Account
                </button>
            </form>
        </div>

        <script>
        document.addEventListener('DOMContentLoaded', function() {
            var form = document.querySelector('form[action*="/register"]');
            var phoneInput = document.getElementById('phoneInput');
            var phoneErrorMsg = document.getElementById('phoneErrorMsg');
            var phoneErrorText = document.getElementById('phoneErrorText');
            var phoneStatusIcon = document.getElementById('phoneStatusIcon');

            if (!phoneInput) return;

            var phoneValidRegex = /^\+?[0-9\s\-]{8,20}$/;

            function validatePhone(showWarning) {
                var val = phoneInput.value;
                var trimmed = val.trim();
                var digits = trimmed.replace(/\D/g, '');

                if (/[a-zA-Z]/.test(val)) {
                    phoneInput.value = val.replace(/[a-zA-Z]/g, '');
                    if (showWarning) {
                        phoneErrorText.textContent = "Letters are not allowed in the phone number. Please enter digits only.";
                        phoneErrorMsg.style.display = "block";
                        phoneInput.style.borderColor = "var(--danger)";
                        phoneStatusIcon.style.display = "block";
                        phoneStatusIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color: var(--danger); font-size: 14px;"></i>';
                    }
                    return false;
                }

                var sanitized = val.replace(/[^0-9+\s-]/g, '');
                if (sanitized !== val) {
                    phoneInput.value = sanitized;
                }

                if (trimmed === "") {
                    if (showWarning) {
                        phoneErrorText.textContent = "Phone number is required.";
                        phoneErrorMsg.style.display = "block";
                        phoneInput.style.borderColor = "var(--danger)";
                        phoneStatusIcon.style.display = "block";
                        phoneStatusIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color: var(--danger); font-size: 14px;"></i>';
                    } else {
                        phoneErrorMsg.style.display = "none";
                        phoneInput.style.borderColor = "var(--border-color)";
                        phoneStatusIcon.style.display = "none";
                    }
                    return false;
                }

                if (digits.length < 8) {
                    if (showWarning) {
                        phoneErrorText.textContent = "Phone number too short (minimum 8 digits required).";
                        phoneErrorMsg.style.display = "block";
                        phoneInput.style.borderColor = "var(--danger)";
                        phoneStatusIcon.style.display = "block";
                        phoneStatusIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color: var(--danger); font-size: 14px;"></i>';
                    }
                    return false;
                }

                if (!phoneValidRegex.test(trimmed)) {
                    if (showWarning) {
                        phoneErrorText.textContent = "Please enter a valid phone number (e.g. +44 7911 123456 or 0771234567).";
                        phoneErrorMsg.style.display = "block";
                        phoneInput.style.borderColor = "var(--danger)";
                        phoneStatusIcon.style.display = "block";
                        phoneStatusIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color: var(--danger); font-size: 14px;"></i>';
                    }
                    return false;
                }

                // Phone is valid
                phoneErrorMsg.style.display = "none";
                phoneInput.style.borderColor = "#10B981";
                phoneStatusIcon.style.display = "block";
                phoneStatusIcon.innerHTML = '<i class="fa-solid fa-circle-check" style="color: #10B981; font-size: 14px;"></i>';
                return true;
            }

            phoneInput.addEventListener('keydown', function(e) {
                if (e.key === 'Backspace' || e.key === 'Delete' || e.key === 'Tab' || 
                    e.key === 'ArrowLeft' || e.key === 'ArrowRight' || e.key === 'Enter' ||
                    (e.ctrlKey || e.metaKey)) {
                    return;
                }
                if (/^[a-zA-Z]$/.test(e.key)) {
                    e.preventDefault();
                    phoneErrorText.textContent = "Letters are not allowed in the phone number. Numbers and + only.";
                    phoneErrorMsg.style.display = "block";
                    phoneInput.style.borderColor = "var(--danger)";
                    phoneStatusIcon.style.display = "block";
                    phoneStatusIcon.innerHTML = '<i class="fa-solid fa-circle-xmark" style="color: var(--danger); font-size: 14px;"></i>';
                }
            });

            phoneInput.addEventListener('input', function() {
                validatePhone(true);
            });

            phoneInput.addEventListener('blur', function() {
                if (phoneInput.value.trim() !== '') {
                    validatePhone(true);
                }
            });

            if (form) {
                form.addEventListener('submit', function(e) {
                    var isValid = validatePhone(true);
                    if (!isValid) {
                        e.preventDefault();
                        phoneInput.focus();
                        phoneInput.style.animation = 'none';
                        phoneInput.offsetHeight;
                        phoneInput.style.animation = 'phoneShake 0.4s ease-in-out';
                    }
                });
            }
        });
        </script>
        <style>
        @keyframes phoneShake {
            0%, 100% { transform: translateX(0); }
            20%, 60% { transform: translateX(-6px); }
            40%, 80% { transform: translateX(6px); }
        }
        </style>

        <div class="card-footer" style="text-align: center; font-size: 13.5px;">
            Already registered? <a href="${pageContext.request.contextPath}/login" style="font-weight: 600;">Sign In</a>
        </div>
    </div>
</div>

<jsp:include page="../layouts/footer.jsp" />
