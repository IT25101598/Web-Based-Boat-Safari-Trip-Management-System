<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${notice != null ? 'Edit Safety Notice' : 'Issue Safety Notice'} | Sail Lanka" />
<jsp:include page="../layouts/header.jsp" />

<div style="background: var(--navy-dark); padding: 120px 0 40px 0; color: #FFFFFF;">
    <div class="container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
        <div>
            <h1 style="font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0 0 6px 0;">
                <c:choose>
                    <c:when test="${notice != null}">Update Maritime Safety Advisory #${notice.id}</c:when>
                    <c:otherwise>Broadcast Emergency & Weather Advisory</c:otherwise>
                </c:choose>
            </h1>
            <p style="color: #94A3B8; margin: 0; font-size: 14.5px;">Broadcast high-priority marine notices to active captains, crew, port control, and passengers.</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/admin/emergency" class="btn btn-outline-gold btn-sm">
                <i class="fa-solid fa-arrow-left"></i> Back to Safety Notices
            </a>
        </div>
    </div>
</div>

<section class="section" style="padding: 40px 0;">
    <div class="container" style="max-width: 820px;">
        <div class="card" style="border-top: 4px solid #EF4444;">
            <div class="card-header" style="background: var(--surface-card); border-bottom: 1px solid var(--border-color); padding: 20px 24px;">
                <h3 style="margin: 0; color: #DC2626; font-size: 20px; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <c:choose>
                        <c:when test="${notice != null}">Modify Active Advisory Details & Directives</c:when>
                        <c:otherwise>Issue Maritime Safety Advisory</c:otherwise>
                    </c:choose>
                </h3>
            </div>
            <div class="card-body" style="padding: 24px;">
                <form action="${pageContext.request.contextPath}/admin/emergency/${notice != null ? 'edit' : 'create'}" method="POST">
                    <input type="hidden" name="csrfToken" value="${csrfToken}" />
                    <c:if test="${notice != null}">
                        <input type="hidden" name="id" value="${notice.id}" />
                    </c:if>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label class="form-label" for="title">Advisory Title <span style="color: #EF4444;">*</span></label>
                        <input type="text" name="title" id="title" class="form-control" 
                               value="${notice != null ? notice.title : ''}"
                               placeholder="e.g., Deep Bay Squall Warning & Monsoon Sea Advisory (Mirissa / Dondra Head)" required />
                    </div>

                    <div class="grid grid-2" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="category">Emergency Category <span style="color: #EF4444;">*</span></label>
                            <select name="category" id="category" class="form-control" required>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.name()}" ${notice != null && notice.category.name() == cat.name() ? 'selected' : ''}>${cat.name()}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="severity">Severity Level <span style="color: #EF4444;">*</span></label>
                            <select name="severity" id="severity" class="form-control" required>
                                <c:forEach var="sev" items="${severities}">
                                    <option value="${sev.name()}" ${(notice != null && notice.severity.name() == sev.name()) || (notice == null && sev.name() == 'HIGH') ? 'selected' : ''}>${sev.name()}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="grid grid-3" style="gap: 20px; margin-bottom: 20px;">
                        <div class="form-group">
                            <label class="form-label" for="affectedRegion">Target Coast / Region</label>
                            <select name="affectedRegion" id="affectedRegion" class="form-control">
                                <option value="ALL_COASTS" ${notice != null && notice.affectedRegion == 'ALL_COASTS' ? 'selected' : ''}>All Sri Lanka Coastal Waters</option>
                                <option value="SOUTH_COAST" ${(notice != null && notice.affectedRegion == 'SOUTH_COAST') || (notice == null) ? 'selected' : ''}>South Coast (Mirissa / Galle / Weligama)</option>
                                <option value="EAST_COAST" ${notice != null && notice.affectedRegion == 'EAST_COAST' ? 'selected' : ''}>East Coast (Trincomalee / Pasikudah)</option>
                                <option value="WEST_COAST" ${notice != null && notice.affectedRegion == 'WEST_COAST' ? 'selected' : ''}>West Coast (Colombo / Negombo / Kalpitiya)</option>
                                <option value="NORTH_COAST" ${notice != null && notice.affectedRegion == 'NORTH_COAST' ? 'selected' : ''}>North Coast (Jaffna / Delft Island)</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="affectedTourId">Affected Safari Tour (Optional)</label>
                            <select name="affectedTourId" id="affectedTourId" class="form-control">
                                <option value="0">-- All Tours in Region --</option>
                                <c:forEach var="t" items="${tours}">
                                    <option value="${t.id}" ${notice != null && notice.affectedTourId == t.id ? 'selected' : ''}>${t.title}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="affectedVesselId">Affected Boat (Optional)</label>
                            <select name="affectedVesselId" id="affectedVesselId" class="form-control">
                                <option value="0">-- All Fleet Vessels --</option>
                                <c:forEach var="v" items="${vessels}">
                                    <option value="${v.id}" ${notice != null && notice.affectedVesselId == v.id ? 'selected' : ''}>${v.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <c:if test="${notice != null}">
                        <div class="form-group" style="margin-bottom: 20px;">
                            <label class="form-label" for="status">Advisory Status</label>
                            <select name="status" id="status" class="form-control">
                                <option value="ACTIVE" ${notice.status.name() == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Broadcast Alert)</option>
                                <option value="RESOLVED" ${notice.status.name() == 'RESOLVED' ? 'selected' : ''}>RESOLVED (All Clear)</option>
                                <option value="CANCELLED" ${notice.status.name() == 'CANCELLED' ? 'selected' : ''}>CANCELLED (Withdrawn)</option>
                            </select>
                        </div>
                    </c:if>

                    <div class="form-group" style="margin-bottom: 20px;">
                        <label class="form-label" for="message">Detailed Advisory Message & Operational Protocol <span style="color: #EF4444;">*</span></label>
                        <textarea name="message" id="message" class="form-control" rows="4" placeholder="Detail weather metrics (wind speed knots, wave height meters), safety precautions, and mandatory actions for captains..." required><c:out value="${notice != null ? notice.message : ''}" /></textarea>
                    </div>

                    <div class="form-group" style="margin-bottom: 24px;">
                        <label class="form-label">Broadcast Channels</label>
                        <div style="display: flex; gap: 20px; margin-top: 8px;">
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500;">
                                <input type="checkbox" name="broadcastChannels" value="PORTAL" checked disabled /> Web Portal Live Ribbon
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500;">
                                <input type="checkbox" name="broadcastChannels" value="SMS" checked /> Passenger SMS Dispatch
                            </label>
                            <label style="display: flex; align-items: center; gap: 8px; font-weight: 500;">
                                <input type="checkbox" name="broadcastChannels" value="EMAIL" checked /> Captain VHF/Email Alert
                            </label>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--border-color); padding-top: 20px;">
                        <a href="${pageContext.request.contextPath}/admin/emergency" class="btn btn-outline-secondary">Cancel</a>
                        <button type="submit" class="btn btn-danger" style="background: #DC2626; color: #FFFFFF; border: none;">
                            <i class="fa-solid ${notice != null ? 'fa-floppy-disk' : 'fa-bullhorn'}"></i>
                            ${notice != null ? 'Save Advisory Updates' : 'Broadcast Emergency Notice'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="../layouts/footer.jsp" />
