<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Emergency Management & Safety Advisories | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">Maritime Safety & Emergency Broadcasts</h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Real-time weather alerts, Department of Meteorology storm advisories, rough sea warnings, and vessel SOS dispatches.</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/admin/emergency/create" class="btn btn-gold btn-sm">
                <i class="fa-solid fa-triangle-exclamation"></i> Issue New Emergency Notice
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container">
        <!-- Status summary banner -->
        <div class="card" style="margin-bottom: 24px; border-left: 4px solid ${activeCount > 0 ? '#EF4444' : '#10B981'};">
            <div class="card-body" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px; padding: 20px 24px;">
                <div style="display: flex; align-items: center; gap: 16px;">
                    <div style="width: 48px; height: 48px; border-radius: 50%; background: ${activeCount > 0 ? '#FEE2E2' : '#D1FAE5'}; color: ${activeCount > 0 ? '#DC2626' : '#059669'}; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                        <i class="fa-solid ${activeCount > 0 ? 'fa-triangle-exclamation' : 'fa-shield-check'}"></i>
                    </div>
                    <div>
                        <h4 style="margin: 0; color: var(--navy-primary); font-size: 18px;">
                            ${activeCount > 0 ? activeCount.toString().concat(' Active High-Priority Safety Advisory in Effect') : 'All Sri Lankan Coastal Waters Clear & Safe for Sailing'}
                        </h4>
                        <p style="margin: 2px 0 0 0; color: var(--text-light); font-size: 14px;">
                            Live ticker on the public portal and guest confirmation pages sync directly with this broadcast table.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Notice ID</th>
                            <th>Category</th>
                            <th>Severity</th>
                            <th>Notice Title & Advisory Details</th>
                            <th>Affected Area / Tour</th>
                            <th>Broadcast Channels</th>
                            <th>Issued Time</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="n" items="${notices}">
                            <tr style="${n.active ? 'background: #FFFBEB;' : ''}">
                                <td>#${n.id}</td>
                                <td><span class="badge badge-outline">${n.category.name()}</span></td>
                                <td><span class="badge ${n.severityBadgeClass}">${n.severity}</span></td>
                                <td>
                                    <div style="font-weight: 700; color: var(--navy-primary); font-size: 15px;">${n.title}</div>
                                    <div style="font-size: 13px; color: #475569; margin-top: 4px;">${n.message}</div>
                                </td>
                                <td>
                                    <c:if test="${n.affectedRegion != null}">
                                        <div><i class="fa-solid fa-location-dot" style="color: var(--champagne-gold);"></i> ${n.affectedRegion}</div>
                                    </c:if>
                                    <c:if test="${n.affectedTourId != null && n.affectedTourId > 0}">
                                        <div style="font-size: 12px; color: var(--text-light);">Safari Tour #${n.affectedTourId}</div>
                                    </c:if>
                                    <c:if test="${n.affectedVesselId != null && n.affectedVesselId > 0}">
                                        <div style="font-size: 12px; color: var(--text-light);">Boat #${n.affectedVesselId}</div>
                                    </c:if>
                                </td>
                                <td>
                                    <span style="font-size: 12px; font-weight: 600; color: var(--navy-primary);">
                                        <i class="fa-solid fa-satellite-dish" style="color: var(--champagne-gold);"></i>
                                        ${n.broadcastChannels}
                                    </span>
                                </td>
                                <td>
                                    <div style="font-size: 13px;">${n.createdAt}</div>
                                    <c:if test="${n.resolvedAt != null}">
                                        <div style="font-size: 11px; color: #059669;">Cleared: ${n.resolvedAt}</div>
                                    </c:if>
                                </td>
                                <td>
                                    <span class="badge ${n.active ? 'badge-danger' : 'badge-success'}">
                                        ${n.status}
                                    </span>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/admin/emergency/edit?id=${n.id}" class="btn btn-outline-gold btn-xs" title="Edit Advisory">
                                            <i class="fa-solid fa-pen-to-square"></i> Edit
                                        </a>
                                        <c:if test="${n.active}">
                                            <form action="${pageContext.request.contextPath}/admin/emergency/resolve" method="POST" style="display: inline;">
                                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                                <input type="hidden" name="id" value="${n.id}" />
                                                <button type="submit" class="btn btn-outline-success btn-xs" title="Mark as Resolved (All-Clear)">
                                                    <i class="fa-solid fa-check"></i> Clear
                                                </button>
                                            </form>
                                        </c:if>
                                        <form action="${pageContext.request.contextPath}/admin/emergency/delete" method="POST" style="display: inline;" onsubmit="return confirm('Archive this emergency notice?');">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                            <input type="hidden" name="id" value="${n.id}" />
                                            <button type="submit" class="btn btn-outline-secondary btn-xs" title="Archive Notice">
                                                <i class="fa-solid fa-trash-can"></i>
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
