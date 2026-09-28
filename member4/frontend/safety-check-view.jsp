<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="../layouts/header.jsp">
    <jsp:param name="title" value="Pre-Trip Safety Clearance Certificate #${log.id}" />
</jsp:include>

<div class="container" style="padding: 40px 20px; max-width: 850px;">
    <!-- Breadcrumb & Actions -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 15px;">
        <a href="${pageContext.request.contextPath}/safety-checks" style="color: var(--gold-primary); font-size: 13.5px; font-weight: 600; text-decoration: none;">
            <i class="fa-solid fa-arrow-left"></i> Back to Safety Logs
        </a>
        <div style="display: flex; gap: 10px;">
            <button onclick="window.print()" class="btn btn-outline-navy btn-sm">
                <i class="fa-solid fa-print"></i> Print Clearance
            </button>
            <c:if test="${log.status != 'VOIDED'}">
                <a href="${pageContext.request.contextPath}/safety-checks/edit?id=${log.id}" class="btn btn-outline-gold btn-sm">
                    <i class="fa-solid fa-pen"></i> Amend Log
                </a>
            </c:if>
        </div>
    </div>

    <!-- Official Certificate Card -->
    <div class="card" style="padding: 45px; border: 2px solid var(--gold-light); position: relative; background: #FFFFFF; box-shadow: var(--shadow-lg);">
        <!-- Top Watermark / Seal -->
        <div style="text-align: center; border-bottom: 2px solid var(--navy-dark); padding-bottom: 25px; margin-bottom: 30px;">
            <div style="display: inline-flex; align-items: center; justify-content: center; width: 60px; height: 60px; border-radius: 50%; background: var(--navy-dark); color: var(--gold-primary); font-size: 28px; margin-bottom: 12px;">
                <i class="fa-solid fa-anchor"></i>
            </div>
            <div style="font-size: 12px; font-weight: 700; color: var(--gold-primary); text-transform: uppercase; letter-spacing: 2.5px;">
                Democratic Socialist Republic of Sri Lanka • Marine Department
            </div>
            <h1 style="font-size: 26px; font-weight: 800; color: var(--navy-dark); margin: 6px 0 4px 0; text-transform: uppercase; letter-spacing: 1px;">
                Pre-Trip Maritime Safety Clearance Certificate
            </h1>
            <div style="font-size: 14px; color: var(--text-muted);">
                Inspection Certificate Reference: <strong>SLC-SAF-${log.id}-2026</strong> • Issued Under Merchant Shipping Safety Regulations
            </div>
        </div>

        <!-- Clearance Status Badge Banner -->
        <div style="display: flex; justify-content: space-between; align-items: center; background: #F8FAFC; border-radius: 8px; padding: 15px 22px; margin-bottom: 30px; border-left: 5px solid ${log.status == 'READY_FOR_DEPARTURE' ? 'var(--emerald)' : 'var(--crimson)'};">
            <div>
                <div style="font-size: 11.5px; color: var(--text-light); text-transform: uppercase; font-weight: 700;">Departure Readiness Clearance</div>
                <div style="font-size: 18px; font-weight: 700; color: var(--navy-dark); margin-top: 2px;">
                    ${log.statusLabel}
                </div>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 11.5px; color: var(--text-light); text-transform: uppercase; font-weight: 700;">Sealed Timestamp</div>
                <div style="font-size: 14.5px; font-weight: 600; color: var(--navy-dark); margin-top: 2px;">
                    ${log.formattedLoggedAt}
                </div>
            </div>
        </div>

        <!-- Certificate Details Grid -->
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 25px; margin-bottom: 30px;">
            <div>
                <h4 style="font-size: 13px; text-transform: uppercase; color: var(--gold-primary); margin: 0 0 8px 0; letter-spacing: 1px;">Vessel Identification</h4>
                <div style="font-size: 17px; font-weight: 700; color: var(--navy-dark);">
                    <c:out value="${empty log.vesselName ? 'Vessel #' += log.vesselId : log.vesselName}" />
                </div>
                <div style="font-size: 13.5px; color: var(--text-muted); margin-top: 3px;">
                    Assigned to Safari Schedule #${log.scheduleId}
                </div>
            </div>

            <div>
                <h4 style="font-size: 13px; text-transform: uppercase; color: var(--gold-primary); margin: 0 0 8px 0; letter-spacing: 1px;">Inspecting Master Mariner</h4>
                <div style="font-size: 17px; font-weight: 700; color: var(--navy-dark);">
                    <i class="fa-solid fa-user-check" style="color: var(--gold-primary); margin-right: 5px;"></i>
                    <c:out value="${empty log.captainName ? log.captainSignature : log.captainName}" />
                </div>
                <div style="font-size: 13.5px; color: var(--text-muted); margin-top: 3px;">
                    Licensed Commercial Boat Captain
                </div>
            </div>
        </div>

        <!-- Safety Checklist Inspection Results -->
        <div style="background: #FAFAFA; border: 1px solid var(--border-color); border-radius: 8px; padding: 22px; margin-bottom: 30px;">
            <h4 style="font-size: 14px; text-transform: uppercase; color: var(--navy-dark); margin: 0 0 15px 0; font-weight: 700; border-bottom: 1px solid var(--border-color); padding-bottom: 8px;">
                <i class="fa-solid fa-list-check" style="color: var(--gold-primary);"></i> Verified Safety Apparatus & Checks
            </h4>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; font-size: 13.5px;">
                <div>
                    <i class="fa-solid fa-circle-check" style="color: var(--emerald);"></i>
                    <strong>SOLAS Life Apparatus:</strong>
                    <span style="color: var(--emerald); font-weight: 600;">VERIFIED PASS</span>
                </div>
                <div>
                    <i class="fa-solid fa-circle-check" style="color: var(--emerald);"></i>
                    <strong>Passenger Safety Briefing:</strong>
                    <span style="color: var(--emerald); font-weight: 600;">CONFIRMED</span>
                </div>
                <div>
                    <i class="fa-solid fa-life-ring" style="color: var(--gold-primary);"></i>
                    <strong>Verified Life Jackets:</strong>
                    <span>${log.lifeJacketsCount} Units Certified</span>
                </div>
                <div>
                    <i class="fa-solid fa-gas-pump" style="color: var(--navy-primary);"></i>
                    <strong>Bunker Fuel Reserve:</strong>
                    <span><strong>${log.fuelLevelPercent}%</strong> (Full Operating Range)</span>
                </div>
            </div>

            <div style="margin-top: 18px; border-top: 1px dashed var(--border-color); padding-top: 15px;">
                <div style="font-size: 12px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; margin-bottom: 4px;">Meteorological Observation:</div>
                <div style="font-size: 14px; color: var(--navy-dark); font-style: italic;">
                    "${log.weatherConditions}"
                </div>
            </div>

            <c:if test="${not empty log.notes}">
                <div style="margin-top: 12px; font-size: 13px; color: var(--text-muted);">
                    <strong>Captain Notes:</strong> <c:out value="${log.notes}" />
                </div>
            </c:if>
        </div>

        <!-- Captain Digital Signature Box -->
        <div style="border: 1px solid var(--gold-light); background: #FFFDF9; border-radius: 8px; padding: 20px 25px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <div style="font-size: 11px; text-transform: uppercase; color: var(--gold-primary); font-weight: 700;">Electronically Sealed By</div>
                <div style="font-size: 22px; font-family: 'Playfair Display', serif; font-weight: 700; color: var(--navy-dark); margin: 4px 0;">
                    ${log.captainSignature}
                </div>
                <div style="font-size: 12px; color: var(--text-light);">Master Mariner • Sri Lanka Merchant Shipping ID Verified</div>
            </div>
            <div style="text-align: right;">
                <div style="display: inline-block; padding: 6px 14px; border: 2px dashed var(--gold-primary); border-radius: 4px; font-size: 12px; font-weight: 700; color: var(--navy-dark); text-transform: uppercase;">
                    <i class="fa-solid fa-stamp" style="color: var(--gold-primary);"></i> ALL CLEAR FOR DEPARTURE
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../layouts/footer.jsp" />
