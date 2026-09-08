<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Activity Logs (Common) | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <div style="color: var(--champagne-gold); font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px;">
                Security & Audit Trail
            </div>
            <h1 style="font-size: 32px; color: #FFFFFF; margin-top: 4px;">System Activity Audit Logs</h1>
            <p style="color: #94A3B8;">Traceable audit logs recording user authentication, bookings, and emergency alerts.</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-gold btn-sm">
            <i class="fa-solid fa-users"></i> Back to User List
        </a>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Timestamp</th>
                            <th>Module</th>
                            <th>Action</th>
                            <th>User ID</th>
                            <th>Details</th>
                            <th>IP Address</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="l" items="${logs}">
                            <tr>
                                <td>#${l.id}</td>
                                <td><span style="font-size: 12px; color: var(--text-light);">${l.createdAt}</span></td>
                                <td><span class="badge badge-primary">${l.module}</span></td>
                                <td><strong>${l.action}</strong></td>
                                <td>${l.userId != null ? l.userId : 'System'}</td>
                                <td>${l.details}</td>
                                <td><code>${l.ipAddress}</code></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
