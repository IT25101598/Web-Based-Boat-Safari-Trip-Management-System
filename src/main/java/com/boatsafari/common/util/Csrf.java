package com.boatsafari.common.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Cross-Site Request Forgery (CSRF) token generation and verification utility.
 * Supports flexible attribute names (_csrf_token, csrfToken, csrf_token) for maximum template compatibility.
 */
public final class Csrf {
    public static final String CSRF_SESSION_KEY = "_csrf_token";
    public static final String CSRF_PARAM_NAME = "csrf_token";
    private static final SecureRandom RANDOM = new SecureRandom();

    private Csrf() {}

    public static String getToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String token = (String) session.getAttribute(CSRF_SESSION_KEY);
        if (token == null) {
            token = (String) session.getAttribute("csrfToken");
        }
        if (token == null) {
            token = (String) session.getAttribute("csrf_token");
        }
        if (token == null) {
            byte[] bytes = new byte[24];
            RANDOM.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(CSRF_SESSION_KEY, token);
            session.setAttribute("csrfToken", token);
            session.setAttribute("csrf_token", token);
        } else {
            session.setAttribute(CSRF_SESSION_KEY, token);
            session.setAttribute("csrfToken", token);
            session.setAttribute("csrf_token", token);
        }
        return token;
    }

    public static boolean validate(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute(CSRF_SESSION_KEY);
        if (sessionToken == null) {
            sessionToken = (String) session.getAttribute("csrfToken");
        }
        if (sessionToken == null) {
            sessionToken = (String) session.getAttribute("csrf_token");
        }
        if (sessionToken == null) return false;

        String paramToken = request.getParameter(CSRF_PARAM_NAME);
        if (paramToken == null) {
            paramToken = request.getParameter("csrfToken");
        }
        if (paramToken == null) {
            paramToken = request.getParameter("_csrf_token");
        }
        return sessionToken.equals(paramToken);
    }
}
