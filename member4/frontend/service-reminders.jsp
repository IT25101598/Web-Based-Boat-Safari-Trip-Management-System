<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Fleet Service Reminders | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Periodic Vessel Service Reminders</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Automated nautical maintenance intervals, engine hour overhauls, and maritime safety certifications.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/maintenance" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-wrench"></i> View Maintenance Logs
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <div class="grid grid-3" style="gap: 30px; align-items: flex-start;">
            <!-- Reminders List (2 cols) -->
            <div style="grid-column: span 2;">
                <div class="card">
                    <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 18px 24px;">
                        <h3 style="margin: 0; color: var(--navy-primary); font-size: 18px;">
                            <i class="fa-solid fa-clock-rotate-left" style="color: var(--champagne-gold); margin-right: 8px;"></i>
                            Configured Routine Service Intervals
                        </h3>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Vessel ID</th>
                                    <th>Service Protocol</th>
                                    <th>Interval</th>
                                    <th>Last Serviced</th>
                                    <th>Next Due Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="r" items="${reminders}">
                                    <tr>
                                        <td><strong>#${r.vesselId}</strong></td>
                                        <td>
                                            <div style="font-weight: 600; color: var(--navy-primary);">${r.reminderTitle}</div>
                                            <div style="font-size: 12px; color: var(--text-light);">${r.notes}</div>
                                        </td>
                                        <td><span class="badge badge-outline">${r.intervalDays} Days</span></td>
                                        <td>${r.lastServicedDate}</td>
                                        <td>
                                            <strong style="color: var(--gold-dark);">${r.nextDueDate}</strong>
                                        </td>
                                        <td>
                                            <span class="badge ${r.overdue ? 'badge-danger' : 'badge-success'}">
                                                ${r.overdue ? 'OVERDUE' : 'UP-TO-DATE'}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Create Reminder Card (1 col) -->
            <div>
                <div class="card">
                    <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 18px 24px;">
                        <h3 style="margin: 0; color: var(--navy-primary); font-size: 18px;">
                            <i class="fa-solid fa-plus-circle" style="color: var(--champagne-gold); margin-right: 8px;"></i>
                            Set Service Alert
                        </h3>
                    </div>
                    <div class="card-body" style="padding: 24px;">
                        <form action="${pageContext.request.contextPath}/admin/maintenance/reminders/create" method="POST">
                            <input type="hidden" name="csrfToken" value="${csrfToken}" />

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label class="form-label" for="vesselId">Vessel <span style="color: #EF4444;">*</span></label>
                                <select name="vesselId" id="vesselId" class="form-control" required>
                                    <option value="">-- Choose Vessel --</option>
                                    <c:forEach var="v" items="${vessels}">
                                        <option value="${v.id}">${v.name} (${v.registrationNumber})</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label class="form-label" for="reminderTitle">Service Title <span style="color: #EF4444;">*</span></label>
                                <input type="text" name="reminderTitle" id="reminderTitle" class="form-control" placeholder="e.g., Generator 100-Hr Servicing" required />
                            </div>

                            <div class="form-group" style="margin-bottom: 16px;">
                                <label class="form-label" for="intervalDays">Recurrence Interval (Days) <span style="color: #EF4444;">*</span></label>
                                <input type="number" name="intervalDays" id="intervalDays" class="form-control" value="90" min="7" max="365" required />
                            </div>

                            <div class="form-group" style="margin-bottom: 20px;">
                                <label class="form-label" for="notes">Surveyor / Check-list Notes</label>
                                <textarea name="notes" id="notes" class="form-control" rows="3" placeholder="Specify OEM filters, oil grade, or survey requirements."></textarea>
                            </div>

                            <button type="submit" class="btn btn-gold btn-block" style="width: 100%;">
                                <i class="fa-solid fa-bell"></i> Save Reminder Alert
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
