<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${record != null && record.id > 0}" />
<c:set var="pageTitle" value="${isEdit ? 'Update Maintenance Task #' : 'Log Maintenance Task'} ${isEdit ? record.id : ''} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">
                ${isEdit ? 'Update Maintenance Log #' : 'Record Maintenance Log'}${isEdit ? record.id : ''}
            </h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">
                ${isEdit ? 'Modify scheduled slipway inspections, recorded expenditures, or contractor surveyor notes.' : 'Schedule slipway inspections, marine diesel servicing, hull scraping, or emergency repairs.'}
            </p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/maintenance" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-arrow-left"></i> Back to Maintenance Logs
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 800px;">
        <div class="card">
            <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 20px 24px;">
                <h3 style="margin: 0; color: var(--navy-primary); font-size: 20px;">
                    <i class="fa-solid fa-wrench" style="color: var(--champagne-gold); margin-right: 8px;"></i>
                    ${isEdit ? 'Edit Maintenance & Repair Work Order' : 'Vessel Maintenance & Inspection Entry'}
                </h3>
            </div>
            <div class="card-body" style="padding: 24px;">
                <form action="${pageContext.request.contextPath}${isEdit ? '/admin/maintenance/edit' : '/admin/maintenance/create'}" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}" />
                    <c:if test="${isEdit}">
                        <input type="hidden" name="id" value="${record.id}" />
                    </c:if>

                    <div class="grid grid-2" style="gap: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="vesselId">Select Vessel <span style="color: #EF4444;">*</span></label>
                            <select name="vesselId" id="vesselId" class="form-control" required>
                                <option value="">-- Choose Boat from Fleet --</option>
                                <c:forEach var="v" items="${vessels}">
                                    <option value="${v.id}" ${record != null && record.vesselId == v.id ? 'selected' : ''}>
                                        ${v.name} (${v.vesselType.displayName} - ${v.registrationNo})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="maintenanceType">Maintenance Classification <span style="color: #EF4444;">*</span></label>
                            <select name="maintenanceType" id="maintenanceType" class="form-control" required>
                                <c:forEach var="t" items="${maintenanceTypes}">
                                    <option value="${t.name()}" ${record != null && record.maintenanceType == t ? 'selected' : ''}>
                                        ${t.title}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group" style="margin-top: 16px;">
                        <label class="form-label" for="description">Maintenance Scope & Task Details <span style="color: #EF4444;">*</span></label>
                        <textarea name="description" id="description" class="form-control" rows="3" placeholder="e.g., Yanmar twin diesel 250-hour oil & impeller service, anti-fouling copper coat touch-up, life raft re-certification." required>${record != null ? record.description : ''}</textarea>
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-top: 16px;">
                        <div class="form-group">
                            <label class="form-label" for="scheduledDate">Scheduled / Commenced Date <span style="color: #EF4444;">*</span></label>
                            <input type="date" name="scheduledDate" id="scheduledDate" class="form-control" value="${record != null ? record.scheduledDate : ''}" required />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="completedDate">Completion Date (Optional)</label>
                            <input type="date" name="completedDate" id="completedDate" class="form-control" value="${record != null ? record.completedDate : ''}" />
                        </div>
                    </div>

                    <div class="grid grid-3" style="gap: 20px; margin-top: 16px;">
                        <div class="form-group">
                            <label class="form-label" for="cost">Repair Cost / Price (LKR) <span style="color: #EF4444;">*</span></label>
                            <input type="number" step="0.01" min="0" name="cost" id="cost" class="form-control" placeholder="0.00" value="${record != null ? record.cost.amount : ''}" required />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="serviceProvider">Contractor / Marine Surveyor</label>
                            <input type="text" name="serviceProvider" id="serviceProvider" class="form-control" placeholder="e.g., Colombo Dockyard Engineering" value="${record != null ? record.serviceProvider : ''}" />
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="status">Work Status <span style="color: #EF4444;">*</span></label>
                            <select name="status" id="status" class="form-control" required>
                                <c:forEach var="s" items="${maintenanceStatuses}">
                                    <option value="${s.name()}" ${record != null && record.status == s ? 'selected' : ''}>
                                        ${s.label}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 30px; border-top: 1px solid var(--border-color); padding-top: 20px;">
                        <a href="${pageContext.request.contextPath}/admin/maintenance" class="btn btn-outline-secondary">Cancel</a>
                        <button type="submit" class="btn btn-gold" id="btnSaveDetails" style="font-weight: 700; padding: 10px 24px;">
                            <i class="fa-solid fa-save"></i> ${isEdit ? 'Update Details' : 'Save Details'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
