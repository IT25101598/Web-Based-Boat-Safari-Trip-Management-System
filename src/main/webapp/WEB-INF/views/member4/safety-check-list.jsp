<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="../layouts/header.jsp">
    <jsp:param name="title" value="Pre-Trip Safety Checks & Boat Readiness" />
</jsp:include>

<div class="container" style="padding: 40px 20px;">
    <!-- Page Header -->
    <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px; flex-wrap: wrap; gap: 20px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: var(--navy-dark); margin: 0 0 6px 0;">
                Pre-Trip Safety Check Logs
            </h1>
            <p style="color: var(--text-muted); margin: 0; font-size: 15px;">
                Official captain safety checklists, SOLAS equipment verification, fuel adequacy, and departure clearance.
            </p>
        </div>
        <div style="display: flex; gap: 12px; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/admin/maintenance" class="btn btn-outline-navy">
                <i class="fa-solid fa-wrench"></i> Dockyard Maintenance
            </a>
            <a href="${pageContext.request.contextPath}/safety-checks/create" class="btn btn-primary">
                <i class="fa-solid fa-square-check"></i> New Pre-Trip Safety Check
            </a>
        </div>
    </div>

    <!-- Alert Messages -->
    <c:if test="${not empty flashSuccess}">
        <div class="alert alert-success" style="margin-bottom: 25px;">
            <i class="fa-solid fa-circle-check"></i> ${flashSuccess}
        </div>
    </c:if>
    <c:if test="${not empty flashError}">
        <div class="alert alert-danger" style="margin-bottom: 25px;">
            <i class="fa-solid fa-triangle-exclamation"></i> ${flashError}
        </div>
    </c:if>

    <!-- Pre-Departure Readiness Notice Banner -->
    <div style="background: linear-gradient(135deg, #0A192F 0%, #1E3A8A 100%); color: #FFFFFF; border-radius: 12px; padding: 22px 28px; margin-bottom: 35px; box-shadow: var(--shadow-md);">
        <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px;">
            <div style="display: flex; align-items: center; gap: 18px;">
                <div style="width: 50px; height: 50px; border-radius: 50%; background: rgba(197, 168, 128, 0.2); display: flex; align-items: center; justify-content: center; font-size: 24px; color: var(--gold-light);">
                    <i class="fa-solid fa-shield-halved"></i>
                </div>
                <div>
                    <h3 style="color: #FFFFFF; margin: 0 0 4px 0; font-size: 18px;">Merchant Shipping Safety Protocol Compliance</h3>
                    <p style="margin: 0; color: rgba(255,255,255,0.75); font-size: 14px;">
                        No vessel is permitted to depart without a validated Captain "All Clear" safety log recorded within 2 hours prior to departure.
                    </p>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/safety-checks/create" class="btn btn-gold" style="white-space: nowrap;">
                <i class="fa-solid fa-check-double"></i> Perform Clearance Check
            </a>
        </div>
    </div>

    <!-- Safety Check Logs Table Card -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 20px 25px; border-bottom: 1px solid var(--border-color); display: flex; justify-content: space-between; align-items: center;">
            <h2 style="font-size: 18px; margin: 0; font-weight: 700; color: var(--navy-dark);">
                Recorded Safety Inspections (${logs.size()})
            </h2>
            <span style="font-size: 13px; color: var(--text-light);">Showing latest pre-trip verifications</span>
        </div>

        <div style="overflow-x: auto;">
            <table class="table" style="margin-bottom: 0;">
                <thead>
                    <tr>
                        <th>Log ID</th>
                        <th>Vessel & Departure</th>
                        <th>Inspecting Captain</th>
                        <th>Fuel & Life Jackets</th>
                        <th>Weather Conditions</th>
                        <th>Readiness Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${logs}">
                        <tr>
                            <td>
                                <strong>#${log.id}</strong>
                                <div style="font-size: 11px; color: var(--text-light); margin-top: 3px;">
                                    ${log.formattedLoggedAt}
                                </div>
                            </td>
                            <td>
                                <div style="font-weight: 600; color: var(--navy-dark);">
                                    <c:out value="${empty log.vesselName ? 'Vessel #' += log.vesselId : log.vesselName}" />
                                </div>
                                <div style="font-size: 12px; color: var(--text-muted);">
                                    <c:out value="${empty log.tourTitle ? 'Tour Schedule #' += log.scheduleId : log.tourTitle}" />
                                </div>
                            </td>
                            <td>
                                <i class="fa-solid fa-user-tie" style="color: var(--gold-primary); margin-right: 4px;"></i>
                                <c:out value="${empty log.captainName ? log.captainSignature : log.captainName}" />
                            </td>
                            <td>
                                <div>
                                    <span class="badge ${log.fuelLevelPercent >= 50 ? 'badge-success' : 'badge-warning'}">
                                        <i class="fa-solid fa-gas-pump"></i> ${log.fuelLevelPercent}% Fuel
                                    </span>
                                </div>
                                <div style="font-size: 12px; color: var(--text-muted); margin-top: 4px;">
                                    <i class="fa-solid fa-life-ring"></i> ${log.lifeJacketsCount} SOLAS Vests
                                </div>
                            </td>
                            <td>
                                <div style="max-width: 250px; font-size: 13px; color: var(--text-main); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${log.weatherConditions}">
                                    <c:out value="${log.weatherConditions}" />
                                </div>
                            </td>
                            <td>
                                <span class="badge ${log.statusBadgeClass}">
                                    ${log.statusLabel}
                                </span>
                            </td>
                            <td>
                                <div style="display: flex; gap: 6px;">
                                    <a href="${pageContext.request.contextPath}/safety-checks/view?id=${log.id}" class="btn btn-outline-navy btn-sm" title="View Safety Certificate">
                                        <i class="fa-solid fa-file-shield"></i> View
                                    </a>
                                    <c:if test="${log.status != 'VOIDED'}">
                                        <a href="${pageContext.request.contextPath}/safety-checks/edit?id=${log.id}" class="btn btn-outline-gold btn-sm" title="Amend / Re-check">
                                            <i class="fa-solid fa-pen"></i> Amend
                                        </a>
                                        <form method="POST" action="${pageContext.request.contextPath}/safety-checks/void" style="display: inline;" onsubmit="return confirm('Are you sure you want to VOID this safety check?');">
                                            <input type="hidden" name="csrf_token" value="${csrfToken}">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}">
                                            <input type="hidden" name="id" value="${log.id}">
                                            <button type="submit" class="btn btn-outline-danger btn-sm" title="Void Entry">
                                                <i class="fa-solid fa-ban"></i> Void
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty logs}">
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-muted);">
                                <i class="fa-solid fa-clipboard-question" style="font-size: 32px; color: var(--gold-primary); margin-bottom: 10px; display: block;"></i>
                                No safety check logs recorded yet. Captains can click "New Pre-Trip Safety Check" to clear a vessel.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="../layouts/footer.jsp" />
