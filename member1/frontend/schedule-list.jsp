<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tour Schedules & Departures | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Tour Schedules & Departures</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Real-time departure calendar, assigned vessels, captains, and seat availability.</p>
        </div>
        <c:if test="${currentUser != null && currentUser.role.staff}">
            <a href="${pageContext.request.contextPath}/admin/schedules/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-plus"></i> Schedule New Departure
            </a>
        </c:if>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Safari Tour</th>
                            <th>Assigned Catamaran</th>
                            <th>Departure Time</th>
                            <th>Return Time</th>
                            <th>Available Seats</th>
                            <th>Operational Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="s" items="${schedules}">
                            <tr>
                                <td>#${s.id}</td>
                                <td><strong>${s.tour != null ? s.tour.title : 'Tour #'.concat(s.tourId)}</strong></td>
                                <td>${s.vesselName != null ? s.vesselName : 'Vessel #'.concat(s.vesselId)}</td>
                                <td>${s.formattedDeparture}</td>
                                <td>${s.formattedReturn}</td>
                                <td><span class="badge badge-primary">${s.availableSeats} Seats</span></td>
                                <td><span class="badge ${s.statusBadgeClass}">${s.statusLabel}</span></td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/booking?tourId=${s.tourId}&scheduleId=${s.id}" class="btn btn-gold btn-sm">
                                            Book Seats
                                        </a>
                                        <c:if test="${currentUser != null && currentUser.role.staff}">
                                            <a href="${pageContext.request.contextPath}/admin/schedules/edit?id=${s.id}" class="btn btn-outline-navy btn-sm" title="Edit Schedule">
                                                <i class="fa-solid fa-pen-to-square"></i> Edit
                                            </a>
                                        </c:if>
                                        <c:if test="${currentUser != null && currentUser.role.staff && s.status.name() == 'SCHEDULED'}">
                                            <form action="${pageContext.request.contextPath}/admin/schedules/cancel" method="POST" onsubmit="return confirm('Cancel this scheduled trip?');" style="display: inline;">
                                                <input type="hidden" name="csrf_token" value="${csrfToken}">
                                                <input type="hidden" name="id" value="${s.id}">
                                                <button type="submit" class="btn btn-danger btn-sm" title="Cancel Departure">
                                                    <i class="fa-solid fa-ban"></i> Cancel
                                                </button>
                                            </form>
                                        </c:if>
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
