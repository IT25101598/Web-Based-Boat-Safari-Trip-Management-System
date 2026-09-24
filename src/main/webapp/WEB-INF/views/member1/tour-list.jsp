<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Safari Tour Management | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Safari Tour Management</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Create, update, schedule, and manage safari tours, routes, and packages.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/admin/schedules" class="btn btn-outline-gold btn-sm">
                <i class="fa-regular fa-calendar-days"></i> View Schedules
            </a>
            <a href="${pageContext.request.contextPath}/admin/tours/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-plus"></i> Create New Tour
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <!-- Search & Filter Form -->
        <div class="card" style="margin-bottom: 24px; padding: 18px 24px; background: var(--surface-card);">
            <form action="${pageContext.request.contextPath}/tours" method="GET" style="display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap;">
                <div style="flex: 2; min-width: 240px;">
                    <label class="form-label" style="font-size: 13px; margin-bottom: 6px;">Search Tours & Keywords</label>
                    <input type="text" name="q" value="${searchQuery}" class="form-control" placeholder="Search by title, highlights, whale watching..." />
                </div>
                <div style="flex: 1; min-width: 200px;">
                    <label class="form-label" style="font-size: 13px; margin-bottom: 6px;">Filter by Category</label>
                    <select name="type" class="form-control">
                        <option value="">All Safari Categories</option>
                        <c:forEach var="tt" items="${tourTypes}">
                            <option value="${tt.name()}" ${typeFilter == tt.name() ? 'selected' : ''}>${tt.title}</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="display: flex; gap: 8px;">
                    <button type="submit" class="btn btn-navy">
                        <i class="fa-solid fa-magnifying-glass"></i> Search
                    </button>
                    <c:if test="${not empty searchQuery or not empty typeFilter}">
                        <a href="${pageContext.request.contextPath}/tours" class="btn btn-outline-secondary">
                            <i class="fa-solid fa-rotate-left"></i> Reset
                        </a>
                    </c:if>
                </div>
            </form>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Tour ID</th>
                            <th>Tour Title</th>
                            <th>Category</th>
                            <th>Duration</th>
                            <th>Base Price</th>
                            <th>Max Pax</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${tours}">
                            <tr>
                                <td>#${t.id}</td>
                                <td>
                                    <strong><a href="${pageContext.request.contextPath}/tours/view?id=${t.id}">${t.title}</a></strong>
                                </td>
                                <td><span class="badge badge-primary">${t.tourType.title}</span></td>
                                <td>${t.durationHours} hrs</td>
                                <td><strong>${t.basePrice.formatted}</strong></td>
                                <td>${t.maxPassengers} guests</td>
                                <td><span class="badge ${t.statusBadgeClass}">${t.statusLabel}</span></td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/admin/tours/edit?id=${t.id}" class="btn btn-outline-navy btn-sm" title="Edit">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </a>
                                        <form action="${pageContext.request.contextPath}/admin/tours/delete" method="POST" onsubmit="return confirm('Are you sure you want to delete this tour?');" style="display: inline;">
                                            <input type="hidden" name="csrf_token" value="${csrfToken}">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                                            <input type="hidden" name="id" value="${t.id}">
                                            <button type="submit" class="btn btn-danger btn-sm" title="Delete">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </div>
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
