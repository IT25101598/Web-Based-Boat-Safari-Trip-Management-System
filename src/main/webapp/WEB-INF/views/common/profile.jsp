<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My Profile | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container">
        <h1 style="font-size: 32px; color: #FFFFFF;">My Account Profile</h1>
        <p style="color: #94A3B8;">Manage your personal details, contact numbers, and security settings.</p>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 680px;">
        <div class="card">
            <div class="card-header">
                <h3 style="font-size: 18px; margin: 0;"><i class="fa-solid fa-user-gear"></i> Account Information</h3>
                <span class="badge badge-primary">${user.role.displayName}</span>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/profile" method="POST">
                    <input type="hidden" name="csrf_token" value="${csrfToken}">

                    <div class="form-group">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="fullName" value="${user.fullName}" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Address (Primary Login)</label>
                        <input type="email" value="${user.email}" class="form-control" disabled style="background: #F1F5F9; color: var(--text-muted);">
                        <small style="font-size: 12px; color: var(--text-light);">Email cannot be modified directly once verified.</small>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Phone Number</label>
                        <input type="text" name="phone" value="${user.phone}" class="form-control">
                    </div>

                    <div class="form-group">
                        <label class="form-label">System Role</label>
                        <input type="text" value="${user.role.displayName}" class="form-control" disabled style="background: #F1F5F9; color: var(--text-muted);">
                    </div>

                    <div style="display: flex; justify-content: flex-end; margin-top: 24px;">
                        <button type="submit" class="btn btn-primary">
                            <i class="fa-solid fa-floppy-disk"></i> Update Profile
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
