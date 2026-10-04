import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn
import os

def create_academic_report(output_path):
    doc = Document()

    # 1 Inch Margins
    for section in doc.sections:
        section.top_margin = Inches(1)
        section.bottom_margin = Inches(1)
        section.left_margin = Inches(1)
        section.right_margin = Inches(1)

    # Color Palette Constants
    COLOR_PRIMARY = RGBColor(11, 12, 13)       # #0B0C0D Dark Editorial
    COLOR_ACCENT = RGBColor(200, 169, 126)    # #C8A97E Warm Champagne Gold
    COLOR_TEXT = RGBColor(35, 35, 35)         # Body Text Dark Charcoal
    COLOR_MUTED = RGBColor(110, 110, 110)     # Muted Text Gray
    COLOR_BG_TINT = "F7F5F0"                   # Warm Soft Tint
    COLOR_DARK_HEX = "0B0C0D"
    COLOR_ACCENT_HEX = "C8A97E"
    COLOR_BORDER_HEX = "D5CFB8"

    def set_cell_background(cell, fill_hex):
        shading_xml = f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>'
        cell._tc.get_or_add_tcPr().append(parse_xml(shading_xml))

    def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = OxmlElement('w:tcMar')
        for margin, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
            node = OxmlElement(f'w:{margin}')
            node.set(qn('w:w'), str(val))
            node.set(qn('w:type'), 'dxa')
            tcMar.append(node)
        tcPr.append(tcMar)

    def add_custom_heading(doc, text, level=1):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(18 if level == 1 else 14)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.bold = True
        if level == 1:
            run.font.size = Pt(18)
            run.font.color.rgb = COLOR_PRIMARY
            run.font.name = 'Georgia'
            pBdr = parse_xml(f'<w:pBdr {nsdecls("w")}><w:bottom w:val="single" w:sz="14" w:space="5" w:color="{COLOR_ACCENT_HEX}"/></w:pBdr>')
            p._p.get_or_add_pPr().append(pBdr)
        elif level == 2:
            run.font.size = Pt(13.5)
            run.font.color.rgb = COLOR_PRIMARY
            run.font.name = 'Arial'
        elif level == 3:
            run.font.size = Pt(11.5)
            run.font.color.rgb = COLOR_ACCENT
            run.font.name = 'Arial'
        return p

    def add_feature_box(doc, title, description, details_list=None):
        table = doc.add_table(rows=1, cols=1)
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = table.cell(0, 0)
        set_cell_background(cell, COLOR_BG_TINT)
        set_cell_margins(cell, top=140, bottom=140, left=180, right=180)

        borders_xml = f'''
        <w:tcBorders {nsdecls("w")}>
            <w:top w:val="none"/>
            <w:left w:val="single" w:sz="24" w:space="0" w:color="{COLOR_ACCENT_HEX}"/>
            <w:bottom w:val="none"/>
            <w:right w:val="none"/>
        </w:tcBorders>
        '''
        cell._tc.get_or_add_tcPr().append(parse_xml(borders_xml))

        p0 = cell.paragraphs[0]
        p0.paragraph_format.space_before = Pt(2)
        p0.paragraph_format.space_after = Pt(4)
        t_run = p0.add_run(f"📌 {title}")
        t_run.bold = True
        t_run.font.size = Pt(11)
        t_run.font.color.rgb = COLOR_PRIMARY
        t_run.font.name = 'Arial'

        dp = cell.add_paragraph()
        dp.paragraph_format.space_before = Pt(2)
        dp.paragraph_format.space_after = Pt(4)
        d_run = dp.add_run(description)
        d_run.font.size = Pt(10.5)
        d_run.font.color.rgb = COLOR_TEXT
        d_run.font.name = 'Calibri'

        if details_list:
            for item in details_list:
                ip = cell.add_paragraph()
                ip.paragraph_format.space_before = Pt(1)
                ip.paragraph_format.space_after = Pt(2)
                irun = ip.add_run(f"  • {item}")
                irun.font.size = Pt(10)
                irun.font.color.rgb = COLOR_TEXT
                irun.font.name = 'Calibri'

        doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # -------------------------------------------------------------
    # HEADER / TITLE SECTION
    # -------------------------------------------------------------
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_p.paragraph_format.space_before = Pt(12)
    title_p.paragraph_format.space_after = Pt(4)

    t_run = title_p.add_run("ACADEMIC PROJECT REPORT")
    t_run.bold = True
    t_run.font.size = Pt(26)
    t_run.font.name = 'Georgia'
    t_run.font.color.rgb = COLOR_PRIMARY

    sub_p = doc.add_paragraph()
    sub_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sub_p.paragraph_format.space_before = Pt(2)
    sub_p.paragraph_format.space_after = Pt(4)
    s_run = sub_p.add_run("FrameFolio — Cinematic Editorial Photography System")
    s_run.bold = True
    s_run.font.size = Pt(15)
    s_run.font.name = 'Arial'
    s_run.font.color.rgb = COLOR_PRIMARY

    meta_p = doc.add_paragraph()
    meta_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    meta_p.paragraph_format.space_before = Pt(2)
    meta_p.paragraph_format.space_after = Pt(14)
    m_run = meta_p.add_run("Course: B.Tech Computer Science Engineering & AI • Cross Platform Application Development (Problem #48)")
    m_run.font.italic = True
    m_run.font.size = Pt(10.5)
    m_run.font.color.rgb = COLOR_MUTED
    m_run.font.name = 'Calibri'

    # Summary Callout Table
    summary_table = doc.add_table(rows=1, cols=1)
    summary_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    s_cell = summary_table.cell(0, 0)
    set_cell_background(s_cell, "FAF6F0")
    set_cell_margins(s_cell, top=120, bottom=120, left=180, right=180)

    pill_border = f'''
    <w:tcBorders {nsdecls("w")}>
        <w:top w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
        <w:left w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
        <w:bottom w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
        <w:right w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
    </w:tcBorders>
    '''
    s_cell._tc.get_or_add_tcPr().append(parse_xml(pill_border))

    sp = s_cell.paragraphs[0]
    sp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sp_run = sp.add_run("⚡ Official 5-Section Academic Evaluation Document: Problem Understanding + Application Design + Implementation + Demonstration + Documentation")
    sp_run.bold = True
    sp_run.font.size = Pt(10)
    sp_run.font.color.rgb = COLOR_PRIMARY
    sp_run.font.name = 'Arial'

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # SECTION 1: PROBLEM UNDERSTANDING
    # -------------------------------------------------------------
    add_custom_heading(doc, "1. Problem Understanding", level=1)

    p1 = doc.add_paragraph()
    p1.paragraph_format.space_before = Pt(4)
    p1.paragraph_format.space_after = Pt(6)
    p1.add_run("This case study addresses the operational challenges faced by professional freelance photographers and creative clients in discovering visual archives and booking photoshoot sessions.").font.size = Pt(11)

    add_custom_heading(doc, "1.1 Assigned Case Study & Objective (Problem #48)", level=2)
    
    add_feature_box(
        doc,
        "Core Problem Statement",
        "Traditional photography booking channels rely on scattered social media messaging, unorganized PDF price lists, and manual scheduling. FrameFolio solves this by establishing a cloud-backed cross-platform application where photographers showcase high-res visual portfolios and clients browse portfolios by specialty category to book session slots.",
        [
          "UI/Widgets Objective: Build Portfolio Upload, Browse Photographers, and Session Booking screens using GridView, Image, and Form widgets.",
          "Styling/Theming Objective: Apply a minimal, image-forward Material 3 theme that lets photography stand out without visual clutter.",
          "Dart Logic Objective: Enforce async/await for cloud image uploads (Cloudinary REST API) and real-time session booking writes (Cloud Firestore).",
          "Production Target: Multi-platform deployment supporting both live Web CDN (Firebase Hosting) and native Mobile (Android APK)."
        ]
    )

    add_custom_heading(doc, "1.2 Key System Requirements Matrix", level=2)

    req_table = doc.add_table(rows=5, cols=3)
    req_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    r_headers = ["Requirement Category", "Required Feature Specification", "Implementation Approach"]
    for i, h in enumerate(r_headers):
        c = req_table.cell(0, i)
        set_cell_background(c, COLOR_DARK_HEX)
        set_cell_margins(c, 100, 100, 100, 100)
        run = c.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    req_data = [
        ("Authentication & Access", "Role-based Authentication (Client vs Photographer)", "Firebase Auth email/password with role field in Firestore users collection"),
        ("Discovery & Portfolio", "Categorized GridView of photographers & Lightbox gallery", "StreamBuilder listening to photographers collection with 75% height card ratio"),
        ("Booking & Reviews", "Package selection cards, Date Picker, and Rating System", "Form validation, subcollection reviews (photographers/{id}/reviews), and rating recalculation"),
        ("Media & Data Storage", "High-res photo upload & NoSQL cloud database", "Cloudinary REST API HTTP Multipart for photos + Cloud Firestore for session documents")
    ]

    for idx, (cat, spec, app) in enumerate(req_data, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        for col_idx, val in enumerate([cat, spec, app]):
            c = req_table.cell(idx, col_idx)
            set_cell_background(c, bg)
            set_cell_margins(c, 80, 80, 80, 80)
            r = c.paragraphs[0].add_run(val)
            r.font.size = Pt(9)
            if col_idx == 0:
                r.bold = True

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # SECTION 2: APPLICATION DESIGN
    # -------------------------------------------------------------
    add_custom_heading(doc, "2. Application Design", level=1)

    p2 = doc.add_paragraph()
    p2.add_run("FrameFolio adopts a dark cinematic editorial design system inspired by high-end fashion and photography magazines. The layout emphasizes imagery over heavy solid controls.").font.size = Pt(11)

    add_custom_heading(doc, "2.1 Visual Color Palette & Design Tokens", level=2)

    color_table = doc.add_table(rows=6, cols=3)
    color_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    c_headers = ["Design Token", "Hex Value", "Usage & Rationale"]
    for i, h in enumerate(c_headers):
        c = color_table.cell(0, i)
        set_cell_background(c, COLOR_DARK_HEX)
        set_cell_margins(c, 100, 100, 100, 100)
        run = c.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    c_data = [
        ("Background Scaffold", "#0B0C0D", "Deep near-black canvas eliminating screen glare and focusing eye on photography"),
        ("Secondary Surface", "#121315", "Card headers, bottom bars, and structural elevation containers"),
        ("Card Container Fill", "#17191B", "Photographer card tiles, package selector cards, and review containers"),
        ("Warm Champagne Accent", "#C8A97E", "Luxury gold accent for star ratings, active selection borders, and primary CTAs"),
        ("Primary Typography", "#F5F3EE", "Warm off-white text ensuring high contrast readability without stark white glare")
    ]

    for idx, (tok, hexv, usage) in enumerate(c_data, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        for col_idx, val in enumerate([tok, hexv, usage]):
            c = color_table.cell(idx, col_idx)
            set_cell_background(c, bg)
            set_cell_margins(c, 80, 80, 80, 80)
            r = c.paragraphs[0].add_run(val)
            r.font.size = Pt(9)
            if col_idx == 1:
                r.bold = True
                r.font.name = 'Consolas'

    add_custom_heading(doc, "2.2 Navigation Architecture & Screen Flow", level=2)
    
    add_feature_box(
        doc,
        "Mobile App Navigation Architecture",
        "FrameFolio uses a role-aware bottom navigation shell (HomeScreen) wrapped in a global MaterialApp with dark Material 3 theme. The navigation hierarchy separates Client discovery from Photographer studio workflows.",
        [
          "SplashScreen: Animated aperture entrance -> Authentication stream check -> Redirect.",
          "LoginScreen: Email/Password Authentication & Role Switcher (Client vs Photographer).",
          "HomeScreen (Shell): Bottom Navigation Bar managing BrowseScreen, BookingsScreen, and PhotographerDashboard.",
          "BrowseScreen -> PhotographerProfileScreen: Parallax header, Selected Works Grid, Lightbox Viewer, and Rating & Reviews.",
          "PhotographerProfileScreen -> BookingScreen -> BookingConfirmationScreen: Package selection, Date picker, Submit booking.",
          "PhotographerDashboard -> PortfolioUploadScreen: ImagePicker -> StorageService (Cloudinary) -> Firestore refresh."
        ]
    )

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # SECTION 3: IMPLEMENTATION
    # -------------------------------------------------------------
    add_custom_heading(doc, "3. Implementation", level=1)

    p3 = doc.add_paragraph()
    p3.add_run("The technical implementation consists of a modular 28-file Dart codebase enforcing clean separation between UI Presentation, Data Models, and Backend Service Gateways.").font.size = Pt(11)

    add_custom_heading(doc, "3.1 Complete 28 Dart Files Breakdown Matrix", level=2)

    files_matrix = [
        ("lib/main.dart", "Root Entry", "WidgetsFlutterBinding, Firebase.initializeApp()"),
        ("lib/app.dart", "App Wrapper", "MaterialApp, AppTheme.darkTheme, SplashScreen route"),
        ("lib/firebase_options.dart", "Config", "Auto-generated Firebase platform credentials (framefolio-efc6a)"),
        ("lib/core/constants/app_constants.dart", "Constants", "Hex colors, collection names, Cloudinary keys"),
        ("lib/core/theme/app_theme.dart", "Theme", "Playfair Display headers + Plus Jakarta Sans body fonts"),
        ("lib/core/widgets/photographer_card.dart", "UI Widget", "75% photo ratio, vignette gradient overlay, Hero tag"),
        ("lib/core/widgets/portfolio_grid.dart", "UI Widget", "GridView.builder + InteractiveViewer full-screen Lightbox"),
        ("lib/core/widgets/loading_widget.dart", "UI Widget", "Centered Champagne progress indicator with message"),
        ("lib/core/widgets/empty_state.dart", "UI Widget", "Dark aperture icon + custom empty feedback message"),
        ("lib/core/widgets/status_chip.dart", "UI Widget", "Pending, Confirmed, Cancelled status badges"),
        ("lib/models/user_model.dart", "Data Model", "UserModel schema: uid, email, name, role"),
        ("lib/models/photographer_model.dart", "Data Model", "PhotographerModel schema: id, rate, bio, averageRating"),
        ("lib/models/booking_model.dart", "Data Model", "BookingModel schema: clientId, package, price, date, status"),
        ("lib/models/review_model.dart", "Data Model", "ReviewModel schema: reviewId, userId, rating, reviewText"),
        ("lib/services/auth_service.dart", "Service", "FirebaseAuth signIn, signUp, signOut, authStateChanges stream"),
        ("lib/services/firestore_service.dart", "Service", "Photographer stream, reviews stream, in-memory Dart sort"),
        ("lib/services/storage_service.dart", "Service", "Cloudinary HTTP Multipart REST API image upload"),
        ("lib/services/seed_service.dart", "Service", "Populates initial sample photographers into Firestore"),
        ("lib/features/splash/splash_screen.dart", "UI Screen", "Animated logo scale effect & delayed Auth redirect"),
        ("lib/features/auth/login_screen.dart", "UI Screen", "Dark input forms for client/photographer authentication"),
        ("lib/features/home/home_screen.dart", "UI Screen", "Bottom NavigationBar shell & role-based routing"),
        ("lib/features/browse/browse_screen.dart", "UI Screen", "Hero banner, Category tabs, Photographer Grid Stream"),
        ("lib/features/browse/photographer_profile_screen.dart", "UI Screen", "Parallax header, PortfolioGrid, Rating & Review Section"),
        ("lib/features/reviews/widgets/review_card.dart", "UI Component", "Review item card with owner edit/delete options"),
        ("lib/features/reviews/widgets/submit_review_dialog.dart", "UI Component", "Interactive 5-star selector & text form validation"),
        ("lib/features/booking/booking_screen.dart", "UI Screen", "Package cards, Date Picker, Firestore booking submit"),
        ("lib/features/booking/bookings_screen.dart", "UI Screen", "Real-time client bookings list with StatusChips"),
        ("lib/features/booking/booking_confirmation_screen.dart", "UI Screen", "Booking success summary screen"),
        ("lib/features/dashboard/photographer_dashboard.dart", "UI Screen", "Earnings stats, incoming bookings, profile actions"),
        ("lib/features/portfolio/portfolio_upload_screen.dart", "UI Screen", "ImagePicker + StorageService Cloudinary upload"),
        ("lib/features/portfolio/portfolio_management_screen.dart", "UI Screen", "Edit starting rate, bio, specialty, portfolio images")
    ]

    fm_table = doc.add_table(rows=len(files_matrix) + 1, cols=3)
    fm_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    fm_headers = ["File Path", "Layer", "Technical Responsibility"]
    for i, h in enumerate(fm_headers):
        c = fm_table.cell(0, i)
        set_cell_background(c, COLOR_DARK_HEX)
        set_cell_margins(c, 100, 100, 100, 100)
        run = c.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    for idx, (path, layer, resp) in enumerate(files_matrix, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        for col_idx, val in enumerate([path, layer, resp]):
            c = fm_table.cell(idx, col_idx)
            set_cell_background(c, bg)
            set_cell_margins(c, 80, 80, 80, 80)
            r = c.paragraphs[0].add_run(val)
            r.font.size = Pt(8.5)
            r.font.name = 'Consolas' if col_idx == 0 else 'Calibri'
            if col_idx == 0:
                r.bold = True

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # SECTION 4: SCREENSHOTS / DEMONSTRATION
    # -------------------------------------------------------------
    add_custom_heading(doc, "4. Screenshots / Demonstration", level=1)

    p4 = doc.add_paragraph()
    p4.add_run("Below is the complete functional demonstration matrix of all FrameFolio mobile application screens.").font.size = Pt(11)

    demo_data = [
        ("Splash Screen", "Animated aperture emblem scaling smoothly on deep #0B0C0D backdrop while checking Firebase authentication state."),
        ("Login / Signup Screen", "Dark editorial input fields with role selection toggle (Client vs Photographer) and form validation."),
        ("Browse Discovery Hub", "Cinematic Hero banner ('Find the photographer behind your next story'), Category Filter Tabs (ALL, WEDDING, PORTRAIT), and 2-column GridView of photographer cards."),
        ("Photographer Profile Screen", "Parallax cover header, PHOTOGRAPHER | LOCATION metadata badge, biography text, and Selected Works photo gallery."),
        ("Interactive Lightbox Viewer", "Full-screen overlay dialog with pinch-to-zoom and pan gestures via InteractiveViewer widget."),
        ("Rating & Review Section", "Rating summary card showing score badge (e.g. 4.7 ★), review count, star breakdown, and real-time StreamBuilder of ReviewCards."),
        ("Submit/Edit Review Dialog", "Interactive 1-to-5 star selector with Form validation (required text, max 500 characters) and async submit progress indicator."),
        ("Session Booking Form", "Package selection cards (Basic, Standard, Premium) with dynamic price calculation, Date Picker, and Time Slot pills."),
        ("Booking Confirmation Screen", "Clean summary screen displaying 'Your story is booked.', booking reference ID, package choice, and Back to Explore CTA."),
        ("Photographer Studio Dashboard", "Studio manager displaying total shoots stats, earnings summary, incoming booking request cards with StatusChips, and quick upload actions."),
        ("Cloudinary Portfolio Upload", "ImagePicker integration uploading high-res photos via REST API to Cloudinary CDN and updating Firestore portfolio array.")
    ]

    d_table = doc.add_table(rows=len(demo_data) + 1, cols=2)
    d_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    d_headers = ["Application Screen / Feature", "Demonstration & Functionality Details"]
    for i, h in enumerate(d_headers):
        c = d_table.cell(0, i)
        set_cell_background(c, COLOR_DARK_HEX)
        set_cell_margins(c, 100, 100, 100, 100)
        run = c.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    for idx, (screen, desc) in enumerate(demo_data, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        c0 = d_table.cell(idx, 0)
        c1 = d_table.cell(idx, 1)
        set_cell_background(c0, bg)
        set_cell_background(c1, bg)
        set_cell_margins(c0, 80, 80, 80, 80)
        set_cell_margins(c1, 80, 80, 80, 80)
        r0 = c0.paragraphs[0].add_run(screen)
        r0.bold = True
        r0.font.size = Pt(9)
        r1 = c1.paragraphs[0].add_run(desc)
        r1.font.size = Pt(9)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # SECTION 5: DOCUMENTATION
    # -------------------------------------------------------------
    add_custom_heading(doc, "5. Documentation", level=1)

    p5 = doc.add_paragraph()
    p5.add_run("This section provides the official project submission documentation, live deployment URLs, and academic evaluation metrics.").font.size = Pt(11)

    add_custom_heading(doc, "5.1 Production Deployment Targets", level=2)

    dep_table = doc.add_table(rows=3, cols=3)
    dep_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    dp_headers = ["Target Platform", "Access URL / File Path", "Deployment Technology"]
    for i, h in enumerate(dp_headers):
        c = dep_table.cell(0, i)
        set_cell_background(c, COLOR_DARK_HEX)
        set_cell_margins(c, 100, 100, 100, 100)
        run = c.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    dep_data = [
        ("Web Platform (Live)", "https://framefolio-efc6a.web.app", "Firebase Hosting CDN (Compiled via flutter build web --release)"),
        ("Android Mobile APK", "FrameFolio.apk (Root Workspace Path)", "Standalone Release APK (Compiled via flutter build apk --release)")
    ]

    for idx, (plat, url, tech) in enumerate(dep_data, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        for col_idx, val in enumerate([plat, url, tech]):
            c = dep_table.cell(idx, col_idx)
            set_cell_background(c, bg)
            set_cell_margins(c, 80, 80, 80, 80)
            r = c.paragraphs[0].add_run(val)
            r.font.size = Pt(9)
            if col_idx == 0:
                r.bold = True
            if col_idx == 1:
                r.font.name = 'Consolas'

    add_custom_heading(doc, "5.2 Official Academic Submission Details", level=2)

    add_feature_box(
        doc,
        "Course & Project Record",
        "This project has been developed and submitted as part of the formal evaluation for Cross Platform Application Development.",
        [
          "Student Name: Sarthak Tajane",
          "Degree Program: B.Tech Computer Science Engineering & AI",
          "Course Title: Cross Platform Application Development",
          "Assigned Case Study: Problem Statement #48 (Photography Portfolio & Booking App)",
          "GitHub Repository: https://github.com/sarthaktajane07/Framefolio",
          "Live Hosted App: https://framefolio-efc6a.web.app",
          "Verification Status: flutter analyze (0 issues found) & flutter test (All tests passed)"
        ]
    )

    doc.save(output_path)
    print(f"Successfully generated Academic Report at: {output_path}")

if __name__ == "__main__":
    output_docx = "/Users/sarthak/Desktop/FrameFolio/FrameFolio_Academic_Project_Report.docx"
    create_academic_report(output_docx)
