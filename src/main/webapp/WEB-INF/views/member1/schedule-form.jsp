<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${schedule != null ? 'Edit Schedule' : 'Schedule Departure'} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">
                ${schedule != null ? 'Modify Scheduled Departure #'.concat(schedule.id.toString()) : 'Schedule Tour Departure'}
            </h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Assign vessel, captain, guide, and calendar departure with automated maritime conflict check.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/schedules" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-arrow-left"></i> Back to Departures
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 760px;">
        <div class="card">
            <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 20px 24px;">
                <h3 style="margin: 0; color: var(--navy-primary); font-size: 18px; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-regular fa-calendar-check" style="color: var(--champagne-gold);"></i>
                    ${schedule != null ? 'Update Departure Details & Re-check Availability' : 'Create New Scheduled Departure'}
                </h3>
            </div>
            <div class="card-body" style="padding: 24px;">
                <form action="${pageContext.request.contextPath}/admin/schedules/${schedule != null ? 'edit' : ''}" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}">
                    <c:if test="${schedule != null}">
                        <input type="hidden" name="id" value="${schedule.id}">
                    </c:if>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label class="form-label">Safari Tour Package <span style="color: var(--danger);">*</span></label>
                        <select name="tourId" class="form-control" required>
                            <c:forEach var="t" items="${tours}">
                                <option value="${t.id}" ${schedule != null && schedule.tourId == t.id ? 'selected' : ''}>
                                    ${t.title} (${t.durationHours} hrs - ${t.basePrice.formatted})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label class="form-label">Assigned Boat / Catamaran <span style="color: var(--danger);">*</span></label>
                        <select name="vesselId" class="form-control" required>
                            <c:forEach var="b" items="${boats}">
                                <option value="${b.id}" ${schedule != null && schedule.vesselId == b.id ? 'selected' : ''}>
                                    ${b.name} (${b.vesselType.displayName}) - Capacity: ${b.capacity.maxPassengers} Pax [${b.status}]
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label">Boat Captain / Master</label>
                            <select name="captainId" class="form-control">
                                <c:forEach var="c" items="${captains}">
                                    <option value="${c.id}" ${schedule != null && schedule.captainId == c.id ? 'selected' : ''}>${c.fullName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Marine Naturalist Guide</label>
                            <select name="guideId" class="form-control">
                                <c:forEach var="g" items="${guides}">
                                    <option value="${g.id}" ${schedule != null && schedule.guideId == g.id ? 'selected' : ''}>${g.fullName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label">Departure Date & Time <span style="color: var(--danger);">*</span></label>
                            <%
                                com.boatsafari.member1.model.TourSchedule sObj = (com.boatsafari.member1.model.TourSchedule) request.getAttribute("schedule");
                                String depVal = "";
                                String retVal = "";
                                if (sObj != null) {
                                    if (sObj.getDepartureTime() != null) {
                                        depVal = sObj.getDepartureTime().toLocalDateTime().toString();
                                        if (depVal.length() > 16) depVal = depVal.substring(0, 16);
                                    }
                                    if (sObj.getReturnTime() != null) {
                                        retVal = sObj.getReturnTime().toLocalDateTime().toString();
                                        if (retVal.length() > 16) retVal = retVal.substring(0, 16);
                                    }
                                }
                            %>
                            <input type="datetime-local" name="departureTime" value="<%= depVal %>" class="form-control" required />
                        </div>
                        <div class="form-group">
                            <label class="form-label">Return Date & Time <span style="color: var(--danger);">*</span></label>
                            <input type="datetime-local" name="returnTime" value="<%= retVal %>" class="form-control" required />
                        </div>
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label">Available Seats <span style="color: var(--danger);">*</span></label>
                            <input type="number" name="availableSeats" value="${schedule != null ? schedule.availableSeats : 22}" min="1" max="60" class="form-control" required />
                        </div>
                        <c:if test="${schedule != null}">
                            <div class="form-group">
                                <label class="form-label">Schedule Status</label>
                                <select name="status" class="form-control">
                                    <option value="SCHEDULED" ${schedule.status.name() == 'SCHEDULED' ? 'selected' : ''}>SCHEDULED (Open for booking)</option>
                                    <option value="BOARDING" ${schedule.status.name() == 'BOARDING' ? 'selected' : ''}>BOARDING (Passengers embarking)</option>
                                    <option value="IN_PROGRESS" ${schedule.status.name() == 'IN_PROGRESS' ? 'selected' : ''}>IN_PROGRESS (At sea)</option>
                                    <option value="COMPLETED" ${schedule.status.name() == 'COMPLETED' ? 'selected' : ''}>COMPLETED (Returned safely)</option>
                                    <option value="CANCELLED" ${schedule.status.name() == 'CANCELLED' ? 'selected' : ''}>CANCELLED (Voyage aborted)</option>
                                </select>
                            </div>
                        </c:if>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--border-color); padding-top: 20px; margin-top: 24px;">
                        <a href="${pageContext.request.contextPath}/admin/schedules" class="btn btn-outline-secondary">Cancel</a>
                        <button type="submit" class="btn btn-gold">
                            <i class="fa-solid ${schedule != null ? 'fa-floppy-disk' : 'fa-calendar-check'}"></i>
                            ${schedule != null ? 'Save Schedule Updates' : 'Publish Departure Schedule'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
