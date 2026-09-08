<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Sign In | Sail Lanka Safari" />
<jsp:include page="../layouts/header.jsp" />

<div class="auth-page-wrapper">
    <div class="card auth-card" style="width: 100%; max-width: 480px; box-shadow: 0 25px 60px rgba(0, 0, 0, 0.55), 0 0 35px rgba(212, 175, 55, 0.2); border: 1px solid rgba(212, 175, 55, 0.35); border-radius: 16px; overflow: hidden; background: rgba(255, 255, 255, 0.98); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); position: relative; z-index: 2;">
        <div class="card-header" style="text-align: center; display: block; padding: 32px 24px 20px 24px; background: #FFFFFF; border-bottom: 1px solid var(--border-color);">
            <div class="logo-symbol" style="margin: 0 auto 14px auto; width: 52px; height: 52px; font-size: 24px; box-shadow: 0 6px 20px rgba(212, 175, 55, 0.4);">
                <i class="fa-solid fa-anchor"></i>
            </div>
            <h2 style="font-size: 24px; color: var(--navy-primary); margin: 0; font-weight: 700;">Sign In to Sail Lanka</h2>
            <p style="font-size: 13.5px; color: var(--text-muted); margin-top: 6px;">Universal access portal for tourists and operations crew</p>
        </div>

        <div class="card-body" style="padding: 28px 24px;">
            <!-- Authentication Form with 2 Buttons: Login and Sign In -->
            <form id="loginForm" action="${pageContext.request.contextPath}/login" method="POST">
                <input type="hidden" name="csrf_token" value="${csrfToken}">
                <input type="hidden" name="returnUrl" value="${param.returnUrl}">

                <div class="form-group" style="margin-bottom: 18px;">
                    <label class="form-label" style="font-weight: 600; font-size: 13.5px; display: block; margin-bottom: 6px;">
                        <i class="fa-solid fa-envelope" style="color: var(--champagne-gold); margin-right: 6px;"></i> Email Address
                    </label>
                    <input type="email" id="loginEmail" name="email" class="form-control" required placeholder="name@domain.com" style="width: 100%; padding: 11px 14px; border: 1px solid var(--border-color); border-radius: 6px; font-size: 14px;">
                </div>

                <div class="form-group" style="margin-bottom: 22px;">
                    <label class="form-label" style="font-weight: 600; font-size: 13.5px; display: block; margin-bottom: 6px;">
                        <i class="fa-solid fa-lock" style="color: var(--champagne-gold); margin-right: 6px;"></i> Password
                    </label>
                    <input type="password" id="loginPassword" name="password" class="form-control" required placeholder="••••••••" style="width: 100%; padding: 11px 14px; border: 1px solid var(--border-color); border-radius: 6px; font-size: 14px;">
                </div>

                <!-- 2 Action Buttons: Login and Sign In -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 10px;">
                    <button type="submit" id="loginBtn" class="btn btn-primary" style="width: 100%; padding: 12px 16px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 14.5px;">
                        <i class="fa-solid fa-right-to-bracket"></i> Login
                    </button>
                    <a href="${pageContext.request.contextPath}/register" id="signInBtn" class="btn btn-outline-gold" style="width: 100%; padding: 12px 16px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; font-size: 14.5px;">
                        <i class="fa-solid fa-user-plus"></i> Sign In
                    </a>
                </div>

                <div style="display: flex; justify-content: space-between; font-size: 12px; color: var(--text-muted); margin-top: 10px; padding: 0 4px;">
                    <span>Have an account? Click <strong>Login</strong></span>
                    <span>New customer? Click <strong>Sign In</strong></span>
                </div>
            </form>
        </div>

        <div class="card-footer" style="text-align: center; font-size: 13.5px; background: #F8FAFC; padding: 18px; border-top: 1px solid var(--border-color);">
            Don't have an account yet? <a href="${pageContext.request.contextPath}/register" style="font-weight: 700; color: var(--navy-primary); text-decoration: underline;">Click Sign In to create an account</a>
        </div>
    </div>
</div>

<jsp:include page="../layouts/footer.jsp" />
