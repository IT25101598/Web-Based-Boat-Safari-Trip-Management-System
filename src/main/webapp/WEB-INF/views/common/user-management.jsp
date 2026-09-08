<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="User Management (Common) | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <div style="color: var(--champagne-gold); font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px;">
                Common Function: RBAC & User Administration
            </div>
            <h1 style="font-size: 32px; color: #FFFFFF; margin-top: 4px;">System Stakeholders & Accounts</h1>
            <p style="color: #94A3B8;">Role-based authentication covering Admin, Officers, Guides, Captains, Owners, and Tourists.</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/activity-logs" class="btn btn-outline-gold btn-sm">
            <i class="fa-solid fa-clock-rotate-left"></i> View Activity Logs
        </a>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <!-- Role Filters -->
        <div style="display: flex; gap: 8px; margin-bottom: 24px; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/admin/users" class="btn ${empty selectedRole ? 'btn-primary' : 'btn-outline-navy'} btn-sm">All Roles</a>
            <c:forEach var="r" items="${roles}">
                <a href="${pageContext.request.contextPath}/admin/users?role=${r.name()}" class="btn ${selectedRole == r.name() ? 'btn-primary' : 'btn-outline-navy'} btn-sm">
                    ${r.displayName}
                </a>
            </c:forEach>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>User ID</th>
                            <th>Full Name</th>
                            <th>Email Address</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Account Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${users}">
                            <tr>
                                <td>#${u.id}</td>
                                <td><strong>${u.fullName}</strong></td>
                                <td>${u.email}</td>
                                <td>${u.phone != null ? u.phone : '-'}</td>
                                <td><span class="badge badge-primary">${u.role.displayName}</span></td>
                                <td><span class="badge ${u.statusBadgeClass}">${u.statusLabel}</span></td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/admin/users/toggle-status" method="POST" style="display: inline;">
                                        <input type="hidden" name="csrf_token" value="${csrfToken}">
                                        <input type="hidden" name="userId" value="${u.id}">
                                        <button type="submit" class="btn btn-sm ${u.active ? 'btn-danger' : 'btn-primary'}">
                                            <i class="fa-solid ${u.active ? 'fa-ban' : 'fa-check'}"></i> ${u.active ? 'Deactivate' : 'Activate'}
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
