<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../layouts/header.jsp">
    <jsp:param name="title" value="Modify Reservation #${reservation.bookingRef}" />
</jsp:include>

<div class="container" style="padding: 40px 20px; max-width: 850px;">
    <!-- Breadcrumb & Header -->
    <div style="margin-bottom: 25px;">
        <a href="${pageContext.request.contextPath}/reservations/view?id=${reservation.id}" style="color: var(--gold-primary); font-size: 13.5px; font-weight: 600; text-decoration: none;">
            <i class="fa-solid fa-arrow-left"></i> Back to Reservation #${reservation.bookingRef}
        </a>
        <h1 style="font-size: 28px; font-weight: 700; color: var(--navy-dark); margin: 10px 0 5px 0;">
            <i class="fa-solid fa-user-pen" style="color: var(--gold-primary);"></i> Modify Reservation Details
        </h1>
        <p style="color: var(--text-muted); font-size: 14.5px; margin: 0;">
            Update scheduled departure, special guest instructions, or amend the passenger manifest before departure.
        </p>
    </div>

    <!-- Error Alerts -->
    <c:if test="${not empty flashError}">
        <div class="alert alert-danger" style="margin-bottom: 25px;">
            <i class="fa-solid fa-triangle-exclamation"></i> ${flashError}
        </div>
    </c:if>

    <!-- Reservation Edit Card -->
    <div class="card" style="padding: 35px; box-shadow: var(--shadow-md);">
        <form method="POST" action="${pageContext.request.contextPath}/reservations/edit">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="id" value="${reservation.id}">

            <!-- Booking Summary -->
            <div style="background: #F8FAFC; border: 1px solid var(--border-color); border-radius: 8px; padding: 18px 22px; margin-bottom: 25px; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px;">
                <div>
                    <div style="font-size: 11.5px; color: var(--text-light); text-transform: uppercase;">Booking Reference</div>
                    <div style="font-size: 16px; font-weight: 700; color: var(--navy-dark); margin-top: 2px;">${reservation.bookingRef}</div>
                </div>
                <div>
                    <div style="font-size: 11.5px; color: var(--text-light); text-transform: uppercase;">Current Tour</div>
                    <div style="font-size: 15px; font-weight: 600; color: var(--navy-dark); margin-top: 2px;">${reservation.tourTitle}</div>
                </div>
                <div>
                    <div style="font-size: 11.5px; color: var(--text-light); text-transform: uppercase;">Total Paid</div>
                    <div style="font-size: 16px; font-weight: 700; color: var(--emerald); margin-top: 2px;">${reservation.finalAmount.formatted}</div>
                </div>
            </div>

            <!-- Schedule Adjustment -->
            <div class="form-group" style="margin-bottom: 25px;">
                <label class="form-label">
                    <i class="fa-solid fa-calendar-day" style="color: var(--gold-primary);"></i> Departure Schedule Selection <span style="color: red;">*</span>
                </label>
                <select name="scheduleId" class="form-control" required>
                    <c:forEach var="sch" items="${schedules}">
                        <option value="${sch.id}" ${reservation.scheduleId == sch.id ? 'selected' : ''}>
                            Schedule #${sch.id} - ${sch.tourTitle} (${sch.formattedDepartureTime}) • Available Seats: ${sch.availableSeats}
                        </option>
                    </c:forEach>
                </select>
                <small style="color: var(--text-muted); margin-top: 4px; display: block;">
                    If re-scheduling, the system will release your existing reserved seats and verify real-time availability on the new departure.
                </small>
            </div>

            <!-- Special Notes / Requests -->
            <div class="form-group" style="margin-bottom: 25px;">
                <label class="form-label">
                    <i class="fa-solid fa-comment-dots" style="color: var(--gold-primary);"></i> Special Requests & Dietary Notes
                </label>
                <textarea name="specialNotes" class="form-control" rows="3" placeholder="e.g. Vegetarian breakfast, anniversary surprise, extra snorkel gear...">${reservation.specialNotes}</textarea>
            </div>

            <!-- Passenger Manifest Modification -->
            <div style="margin-bottom: 30px;">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--navy-dark); border-bottom: 2px solid var(--gold-light); padding-bottom: 8px; margin-bottom: 15px;">
                    <i class="fa-solid fa-users" style="color: var(--gold-primary);"></i> Passenger Manifest Details
                </h3>

                <div id="passengerContainer">
                    <c:forEach var="p" items="${reservation.passengers}" varStatus="status">
                        <div class="passenger-row" style="background: #FAFAFA; border: 1px solid var(--border-color); border-radius: 8px; padding: 18px; margin-bottom: 15px;">
                            <div style="font-weight: 700; font-size: 13.5px; color: var(--navy-dark); margin-bottom: 10px;">
                                Passenger #${status.index + 1}
                            </div>
                            <div style="display: grid; grid-template-columns: 2fr 1.5fr 1fr 1fr; gap: 12px;">
                                <div>
                                    <label style="font-size: 12px; color: var(--text-muted);">Full Name</label>
                                    <input type="text" name="passengerName" class="form-control form-control-sm" required value="${p.fullName}">
                                </div>
                                <div>
                                    <label style="font-size: 12px; color: var(--text-muted);">ID / Passport</label>
                                    <input type="text" name="idOrPassport" class="form-control form-control-sm" required value="${p.idOrPassport}">
                                </div>
                                <div>
                                    <label style="font-size: 12px; color: var(--text-muted);">Age</label>
                                    <input type="number" name="age" class="form-control form-control-sm" min="1" max="100" required value="${p.age}">
                                </div>
                                <div>
                                    <label style="font-size: 12px; color: var(--text-muted);">Gender</label>
                                    <select name="gender" class="form-control form-control-sm">
                                        <option value="MALE" ${p.gender == 'MALE' ? 'selected' : ''}>Male</option>
                                        <option value="FEMALE" ${p.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                                        <option value="OTHER" ${p.gender == 'OTHER' ? 'selected' : ''}>Other</option>
                                    </select>
                                    <input type="hidden" name="nationality" value="${empty p.nationality ? 'Sri Lankan' : p.nationality}">
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <!-- Submit Button -->
            <div style="display: flex; justify-content: flex-end; gap: 15px; border-top: 1px solid var(--border-color); padding-top: 20px;">
                <a href="${pageContext.request.contextPath}/reservations/view?id=${reservation.id}" class="btn btn-outline-navy">
                    Cancel
                </a>
                <button type="submit" class="btn btn-primary" style="padding: 12px 28px; font-size: 15px;">
                    <i class="fa-solid fa-floppy-disk"></i> Save Modified Booking
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../layouts/footer.jsp" />
