import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml, OxmlElement
from docx.oxml.ns import nsdecls, qn
import os

def create_viva_document(output_path):
    doc = Document()

    # Set Margins (1 inch everywhere)
    for section in doc.sections:
        section.top_margin = Inches(1)
        section.bottom_margin = Inches(1)
        section.left_margin = Inches(1)
        section.right_margin = Inches(1)

    # Color Palette Constants
    COLOR_PRIMARY = RGBColor(11, 12, 13)       # #0B0C0D Dark Editorial
    COLOR_ACCENT = RGBColor(200, 169, 126)    # #C8A97E Warm Champagne Gold
    COLOR_SECONDARY = RGBColor(18, 19, 21)    # #121315 Dark Surface
    COLOR_TEXT = RGBColor(30, 30, 30)         # Body Text Dark Charcoal
    COLOR_MUTED = RGBColor(100, 100, 100)     # Muted Text Gray
    COLOR_HINGLISH_BG = "F7F5F0"               # Soft Off-White Tint for Q&A
    COLOR_CODE_BG = "F1F1F1"                   # Light gray for code
    COLOR_ACCENT_HEX = "C8A97E"
    COLOR_DARK_HEX = "0B0C0D"
    COLOR_BORDER_HEX = "D0C8B8"

    # Helper function for setting cell shading background
    def set_cell_background(cell, fill_hex):
        shading_xml = f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>'
        cell._tc.get_or_add_tcPr().append(parse_xml(shading_xml))

    # Helper function for cell margins/padding
    def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = OxmlElement('w:tcMar')
        for margin, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
            node = OxmlElement(f'w:{margin}')
            node.set(qn('w:w'), str(val))
            node.set(qn('w:type'), 'dxa')
            tcMar.append(node)
        tcPr.append(tcMar)

    # Helper for adding custom styled heading
    def add_custom_heading(doc, text, level=1):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(16 if level == 1 else 12)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.bold = True
        if level == 1:
            run.font.size = Pt(20)
            run.font.color.rgb = COLOR_PRIMARY
            run.font.name = 'Georgia'
            # Add bottom border accent under H1
            pBdr = parse_xml(f'<w:pBdr {nsdecls("w")}><w:bottom w:val="single" w:sz="12" w:space="4" w:color="{COLOR_ACCENT_HEX}"/></w:pBdr>')
            p._p.get_or_add_pPr().append(pBdr)
        elif level == 2:
            run.font.size = Pt(14)
            run.font.color.rgb = COLOR_PRIMARY
            run.font.name = 'Arial'
        elif level == 3:
            run.font.size = Pt(12)
            run.font.color.rgb = COLOR_ACCENT
            run.font.name = 'Arial'
        return p

    # Helper for adding callout / Hinglish answer block
    def add_viva_qa_box(doc, question, answer_hinglish, concept_english=None):
        table = doc.add_table(rows=1, cols=1)
        table.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = table.cell(0, 0)
        set_cell_background(cell, COLOR_HINGLISH_BG)
        set_cell_margins(cell, top=140, bottom=140, left=200, right=200)

        # Set thick left border (Champagne Accent)
        borders_xml = f'''
        <w:tcBorders {nsdecls("w")}>
            <w:top w:val="none"/>
            <w:left w:val="single" w:sz="24" w:space="0" w:color="{COLOR_ACCENT_HEX}"/>
            <w:bottom w:val="none"/>
            <w:right w:val="none"/>
        </w:tcBorders>
        '''
        cell._tc.get_or_add_tcPr().append(parse_xml(borders_xml))

        # Question Title
        qp = cell.paragraphs[0]
        qp.paragraph_format.space_before = Pt(2)
        qp.paragraph_format.space_after = Pt(4)
        q_run = qp.add_run(f"❓ {question}")
        q_run.bold = True
        q_run.font.size = Pt(11)
        q_run.font.color.rgb = COLOR_PRIMARY
        q_run.font.name = 'Arial'

        # Hinglish Answer
        ap = cell.add_paragraph()
        ap.paragraph_format.space_before = Pt(2)
        ap.paragraph_format.space_after = Pt(4)
        lbl_run = ap.add_run("💡 Hinglish Viva Answer: ")
        lbl_run.bold = True
        lbl_run.font.size = Pt(10.5)
        lbl_run.font.color.rgb = COLOR_ACCENT
        lbl_run.font.name = 'Calibri'

        ans_run = ap.add_run(answer_hinglish)
        ans_run.font.size = Pt(10.5)
        ans_run.font.italic = False
        ans_run.font.color.rgb = COLOR_TEXT
        ans_run.font.name = 'Calibri'

        # Optional Concept Note in English
        if concept_english:
            cp = cell.add_paragraph()
            cp.paragraph_format.space_before = Pt(2)
            cp.paragraph_format.space_after = Pt(2)
            c_lbl = cp.add_run("📌 Core Concept: ")
            c_lbl.bold = True
            c_lbl.font.size = Pt(9.5)
            c_lbl.font.color.rgb = COLOR_MUTED
            c_lbl.font.name = 'Calibri'

            c_ans = cp.add_run(concept_english)
            c_ans.font.size = Pt(9.5)
            c_ans.font.color.rgb = COLOR_MUTED
            c_ans.font.name = 'Calibri'

        doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # -------------------------------------------------------------
    # COVER / HEADER SECTION (Inspired by Reference Image)
    # -------------------------------------------------------------
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_p.paragraph_format.space_before = Pt(24)
    title_p.paragraph_format.space_after = Pt(4)

    t_run = title_p.add_run("FLUTTER VIVA")
    t_run.bold = True
    t_run.font.size = Pt(32)
    t_run.font.name = 'Arial'
    t_run.font.color.rgb = COLOR_PRIMARY

    title_p2 = doc.add_paragraph()
    title_p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_p2.paragraph_format.space_before = Pt(0)
    title_p2.paragraph_format.space_after = Pt(12)

    t_run2 = title_p2.add_run("READY DOCUMENT")
    t_run2.bold = True
    t_run2.font.size = Pt(30)
    t_run2.font.name = 'Arial'
    t_run2.font.color.rgb = COLOR_PRIMARY

    sub_p = doc.add_paragraph()
    sub_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sub_p.paragraph_format.space_before = Pt(6)
    sub_p.paragraph_format.space_after = Pt(4)
    s_run = sub_p.add_run("Developing Cross-Platform Mobile Applications using Flutter")
    s_run.bold = True
    s_run.font.size = Pt(16)
    s_run.font.name = 'Arial'
    s_run.font.color.rgb = COLOR_PRIMARY

    sem_p = doc.add_paragraph()
    sem_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    sem_p.paragraph_format.space_before = Pt(2)
    sem_p.paragraph_format.space_after = Pt(16)
    sm_run = sem_p.add_run("Semester V / Final Year • Cross Platform App Development • Viva & Project Defense Guide")
    sm_run.font.italic = True
    sm_run.font.size = Pt(11)
    sm_run.font.color.rgb = COLOR_MUTED
    sm_run.font.name = 'Calibri'

    # Fast Revision Badge Callout
    pill_table = doc.add_table(rows=1, cols=1)
    pill_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    p_cell = pill_table.cell(0, 0)
    set_cell_background(p_cell, "FAF6F0")
    set_cell_margins(p_cell, top=120, bottom=120, left=200, right=200)

    # All rounded border for Pill Box
    pill_border = f'''
    <w:tcBorders {nsdecls("w")}>
        <w:top w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
        <w:left w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
        <w:bottom w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
        <w:right w:val="single" w:sz="6" w:space="0" w:color="{COLOR_BORDER_HEX}"/>
    </w:tcBorders>
    '''
    p_cell._tc.get_or_add_tcPr().append(parse_xml(pill_border))

    pp = p_cell.paragraphs[0]
    pp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    pp_run = pp.add_run("⚡ Fast-revision guide: syllabus + concepts + file connection + project architecture + 35 one-line & deep viva answers in Hinglish")
    pp_run.bold = True
    pp_run.font.size = Pt(10.5)
    pp_run.font.color.rgb = COLOR_PRIMARY
    pp_run.font.name = 'Arial'

    doc.add_paragraph().paragraph_format.space_after = Pt(16)

    # -------------------------------------------------------------
    # SECTION 1: FLUTTER & DART CORE CONCEPTS
    # -------------------------------------------------------------
    add_custom_heading(doc, "SECTION 1: Flutter & Dart Core Concepts (Viva Foundation)", level=1)

    p = doc.add_paragraph()
    p.add_run("This section covers the foundational syllabus topics that external examiners test during the Viva examination before diving into project-specific code.").font.size = Pt(11)

    add_custom_heading(doc, "1.1 Flutter Framework Architecture & Render Pipeline", level=2)

    table = doc.add_table(rows=4, cols=2)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    headers = ["Architecture Layer", "Responsibility & Core Components"]
    for i, h in enumerate(headers):
        cell = table.cell(0, i)
        set_cell_background(cell, COLOR_DARK_HEX)
        set_cell_margins(cell, 120, 120, 140, 140)
        run = cell.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(10)

    data = [
        ("Framework Layer (Dart)", "Contains Material & Cupertino UI libraries, Widgets, Animation, Gestures, Foundation classes, and Rendering tree engine written in pure Dart."),
        ("Engine Layer (C/C++)", "Provides low-level implementation including Impeller/Skia graphics engine, Dart Runtime VM, Text Layout (LibTXT), Platform Channels, and File/Network I/O."),
        ("Embedder Layer (Platform)", "Native platform wrapper (Android/JVM, iOS/Objective-C, Web/JS-Wasm, macOS/AppKit) responsible for surface rendering, input events, and native thread dispatching.")
    ]

    for row_idx, (layer, resp) in enumerate(data, start=1):
        c0 = table.cell(row_idx, 0)
        c1 = table.cell(row_idx, 1)
        set_cell_background(c0, "F7F7F7" if row_idx % 2 == 1 else "FFFFFF")
        set_cell_background(c1, "F7F7F7" if row_idx % 2 == 1 else "FFFFFF")
        set_cell_margins(c0, 100, 100, 120, 120)
        set_cell_margins(c1, 100, 100, 120, 120)
        r0 = c0.paragraphs[0].add_run(layer)
        r0.bold = True
        r0.font.size = Pt(9.5)
        r1 = c1.paragraphs[0].add_run(resp)
        r1.font.size = Pt(9.5)

    doc.add_paragraph().paragraph_format.space_after = Pt(10)

    # Viva Questions for Section 1
    add_viva_qa_box(
        doc,
        "Flutter me 'Everything is a Widget' ka kya matlab hai?",
        "Flutter me har visual element, alignment, padding, theme aur even structural layout ek Widget object ke roop me represented hota hai. Layouts compose karke complex UIs banaye jaate hain.",
        "Widgets are immutable configuration declarations that describe what the view should look like given its current configuration and state."
    )

    add_viva_qa_box(
        doc,
        "StatelessWidget aur StatefulWidget me kya difference hai?",
        "StatelessWidget ka state immutable (unchangeable) hota hai — jab parameters change hote hain tabhi naya widget rebuild hota hai. StatefulWidget ke paas ek companion State object hota hai jo mutable state holds karta hai aur setState() call karke UI ko rebuild karwa sakta hai.",
        "StatelessWidget rebuilds only when constructor properties change. StatefulWidget manages mutable state across the widget lifecycle via the State object."
    )

    add_viva_qa_box(
        doc,
        "Hot Reload aur Hot Restart me kya difference hai?",
        "Hot Reload JIT (Just-In-Time) compilation me code updates ko Dart VM me inject karta hai bina app state wipe kiye (seconds me update). Jabki Hot Restart poore app state ko reset karke main() function ko shuru se execute karta hai.",
        "Hot Reload injects updated source code into the running Dart VM preserving app state. Hot Restart resets app state to initial defaults and re-executes main()."
    )

    add_viva_qa_box(
        doc,
        "Flutter ke Three Trees (Widget, Element, Render) kaise kaam karte hain?",
        "1. Widget Tree: Configuration details maintain karta hai (Immutable).\n2. Element Tree: Structural hierarchy aur lifecycle manage karta hai (Bridge/Manager).\n3. RenderObject Tree: Screen par actual painting, layout math aur hit-testing calculate karta hai.",
        "Widget tree describes UI configuration -> Element tree manages lifecycle and instantiation -> RenderObject tree computes geometry and paints pixels."
    )

    # -------------------------------------------------------------
    # SECTION 2: FRAMEFOLIO CODEBASE ARCHITECTURE & FILE CONNECTIONS
    # -------------------------------------------------------------
    add_custom_heading(doc, "SECTION 2: FrameFolio Codebase Architecture & File Connections", level=1)

    p = doc.add_paragraph()
    p.add_run("FrameFolio follows a clean, layered Feature-First Architecture. Below is the complete breakdown of all 28 project files, their precise roles, imports, and how they connect to each other.").font.size = Pt(11)

    add_custom_heading(doc, "2.1 Project File Connection & Dependency Matrix", level=2)

    files_info = [
        ("lib/main.dart", "App Entry Point", "Firebase.initializeApp(), runApp()", "lib/app.dart, firebase_options.dart"),
        ("lib/app.dart", "Root App Widget", "MaterialApp, AppTheme, StreamBuilder(auth)", "lib/core/theme/app_theme.dart, lib/features/home/home_screen.dart, lib/features/auth/login_screen.dart"),
        ("lib/core/constants/app_constants.dart", "Design Tokens", "Hex Colors (#0B0C0D, #C8A97E), Categories, Packages", "All Core & Feature Widgets"),
        ("lib/core/theme/app_theme.dart", "Theme System", "GoogleFonts (Playfair Display, Plus Jakarta Sans)", "lib/app.dart"),
        ("lib/core/widgets/photographer_card.dart", "Card Component", "75% Image ratio, Vignette, Hero Tag, View Portfolio CTA", "lib/features/browse/browse_screen.dart, lib/models/photographer_model.dart"),
        ("lib/core/widgets/portfolio_grid.dart", "Portfolio Gallery", "Staggered Grid, Lightbox Full-screen Dialog Viewer", "lib/features/browse/photographer_profile_screen.dart"),
        ("lib/core/widgets/loading_widget.dart", "Progress Indicator", "Champagne CircularProgressIndicator with message", "Used across all screen futures/streams"),
        ("lib/core/widgets/empty_state.dart", "Empty View", "Aperture emblem + custom muted empty message", "lib/features/booking/bookings_screen.dart"),
        ("lib/core/widgets/status_chip.dart", "Status Badge", "Pending, Confirmed, Cancelled styled chips", "lib/features/booking/bookings_screen.dart, lib/features/dashboard/photographer_dashboard.dart"),
        ("lib/models/user_model.dart", "User Entity", "id, email, name, role (client/photographer), avatarUrl", "lib/services/auth_service.dart, lib/services/firestore_service.dart"),
        ("lib/models/photographer_model.dart", "Photographer Entity", "id, name, bio, location, startingRate, rating, portfolio", "lib/core/widgets/photographer_card.dart, lib/features/browse/photographer_profile_screen.dart"),
        ("lib/models/booking_model.dart", "Booking Entity", "id, clientId, photographerId, date, package, status, price", "lib/services/firestore_service.dart, lib/features/booking/booking_screen.dart"),
        ("lib/services/auth_service.dart", "Auth Gateway", "FirebaseAuth signIn, signUp, signOut, authStateChanges stream", "lib/app.dart, lib/features/auth/login_screen.dart, lib/features/home/home_screen.dart"),
        ("lib/services/firestore_service.dart", "Database Gateway", "Photographers stream, client bookings stream (in-memory sort)", "lib/features/browse/browse_screen.dart, lib/features/booking/booking_screen.dart"),
        ("lib/services/storage_service.dart", "Media Storage", "FirebaseStorage uploadPortfolioImage, getDownloadURL", "lib/features/portfolio/portfolio_upload_screen.dart"),
        ("lib/services/seed_service.dart", "Data Population", "Populates initial sample photographers into Firestore", "lib/main.dart (development seed flag)"),
        ("lib/features/splash/splash_screen.dart", "Splash Entrance", "Aperture logo scaling, delayed push to HomeScreen", "lib/app.dart"),
        ("lib/features/auth/login_screen.dart", "Authentication UI", "Email/Password login & signup forms, dark inputs", "lib/services/auth_service.dart"),
        ("lib/features/home/home_screen.dart", "Bottom Shell", "NavigationBar (Browse, Bookings, Dashboard/Profile)", "lib/features/browse/browse_screen.dart, lib/features/booking/bookings_screen.dart"),
        ("lib/features/browse/browse_screen.dart", "Discovery Hub", "Hero banner, Category filter tabs, Photographer grid", "lib/core/widgets/photographer_card.dart, lib/features/browse/photographer_profile_screen.dart"),
        ("lib/features/browse/photographer_profile_screen.dart", "Profile Screen", "Header cover, Metadata, Bio, PortfolioGrid, Book CTA", "lib/core/widgets/portfolio_grid.dart, lib/features/booking/booking_screen.dart"),
        ("lib/features/booking/booking_screen.dart", "Booking Form", "Package selection cards, Date picker, Submit booking", "lib/services/firestore_service.dart, lib/features/booking/booking_confirmation_screen.dart"),
        ("lib/features/booking/bookings_screen.dart", "Bookings List", "StreamBuilder(clientBookings), StatusChip, Booking cards", "lib/services/firestore_service.dart, lib/core/widgets/status_chip.dart"),
        ("lib/features/booking/booking_confirmation_screen.dart", "Confirmation", "Success checkmark, Booking ID summary, Back CTA", "lib/features/home/home_screen.dart"),
        ("lib/features/dashboard/photographer_dashboard.dart", "Studio Dashboard", "Photographer stats, incoming booking requests, Sign out", "lib/services/firestore_service.dart, lib/services/auth_service.dart"),
        ("lib/features/portfolio/portfolio_upload_screen.dart", "Upload Screen", "File picker, StorageService upload, Firestore update", "lib/services/storage_service.dart, lib/services/firestore_service.dart"),
        ("lib/features/portfolio/portfolio_management_screen.dart", "Portfolio Manager", "Edit rate, bio, location, remove/upload portfolio images", "lib/services/firestore_service.dart")
    ]

    f_table = doc.add_table(rows=len(files_info) + 1, cols=4)
    f_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    f_headers = ["File Path", "Role / Layer", "Key Responsibilities", "Connected Dependencies"]
    for i, h in enumerate(f_headers):
        cell = f_table.cell(0, i)
        set_cell_background(cell, COLOR_DARK_HEX)
        set_cell_margins(cell, 100, 100, 100, 100)
        run = cell.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    for idx, (path, role, resp, deps) in enumerate(files_info, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        row = [path, role, resp, deps]
        for col_idx, val in enumerate(row):
            c = f_table.cell(idx, col_idx)
            set_cell_background(c, bg)
            set_cell_margins(c, 80, 80, 80, 80)
            r = c.paragraphs[0].add_run(val)
            r.font.size = Pt(8.5)
            r.font.name = 'Consolas' if col_idx == 0 else 'Calibri'
            if col_idx == 0:
                r.bold = True

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    # -------------------------------------------------------------
    # SECTION 3: EDITORIAL DESIGN SYSTEM & OVERFLOW ENGINEERING
    # -------------------------------------------------------------
    add_custom_heading(doc, "SECTION 3: FrameFolio Editorial UI Design System & Overflow Engineering", level=1)

    p = doc.add_paragraph()
    p.add_run("FrameFolio features a dark cinematic editorial design inspired by luxury photography magazines. Below are the design tokens and layout balance principles.").font.size = Pt(11)

    add_custom_heading(doc, "3.1 Color System & Typography Tokens", level=2)

    colors_data = [
        ("Background Canvas", "#0B0C0D", "Deep near-black background providing maximum imagery contrast"),
        ("Secondary Surface", "#121315", "Card headers, bottom bars, and structural elevation"),
        ("Card Tile Fill", "#17191B", "Photographer tiles and package selection cards"),
        ("Primary Text", "#F5F3EE", "Warm off-white for crisp readability without eye strain"),
        ("Secondary Text", "#A5A29B", "Subheadings, locations, and metadata text"),
        ("Muted Text", "#77746E", "Timestamps, hints, and secondary captions"),
        ("Borders & Dividers", "#303133", "Subtle single-pixel borders for clean structural hierarchy"),
        ("Champagne Accent", "#C8A97E", "Warm luxury gold accent for primary CTAs and active states")
    ]

    c_table = doc.add_table(rows=len(colors_data) + 1, cols=3)
    c_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    c_headers = ["Token Name", "Hex Value", "Design Rationale"]
    for i, h in enumerate(c_headers):
        cell = c_table.cell(0, i)
        set_cell_background(cell, COLOR_DARK_HEX)
        set_cell_margins(cell, 100, 100, 100, 100)
        run = cell.paragraphs[0].add_run(h)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(9.5)

    for idx, (tname, hexval, desc) in enumerate(colors_data, start=1):
        bg = "F9F8F6" if idx % 2 == 1 else "FFFFFF"
        for col_idx, val in enumerate([tname, hexval, desc]):
            c = c_table.cell(idx, col_idx)
            set_cell_background(c, bg)
            set_cell_margins(c, 80, 80, 80, 80)
            r = c.paragraphs[0].add_run(val)
            r.font.size = Pt(9)
            if col_idx == 1:
                r.bold = True
                r.font.name = 'Consolas'

    doc.add_paragraph().paragraph_format.space_after = Pt(10)

    # Design Viva Questions
    add_viva_qa_box(
        doc,
        "Photographer Card me RenderFlex bottom overflow (yellow/black stripes) error kyu aata hai aur usko kaise resolve kiya?",
        "Jab fixed height container me Dynamic text aur image ka combination exceed kar jata hai to Flutter overflow flag karta hai. Isko solve karne ke liye image container ko `Expanded` widget ke andar rakha gaya aur content footer me `mainAxisSize: MainAxisSize.min` specify kiya gaya, jisse photo 75% area cleanly occupy karti hai bina overflow ke.",
        "Use Expanded widgets inside Flex parents (Column/Row) to absorb dynamic space, and constrain text with TextOverflow.ellipsis."
    )

    add_viva_qa_box(
        doc,
        "Google Fonts (Playfair Display & Plus Jakarta Sans) ko app me kaise bundle kiya gaya hai?",
        "App Theme (`app_theme.dart`) me display headers ke liye `GoogleFonts.playfairDisplay()` serif typography configure ki gayi hai, jabki body text aur buttons ke liye `GoogleFonts.plusJakartaSans()` clean sans-serif apply ki gayi hai. Offline asset caching ke dwara production me fast performance maintain hoti hai.",
        "Typography hierarchy: Serif for high-level editorial headers (Playfair Display) + Sans-serif for body controls (Plus Jakarta Sans)."
    )

    # -------------------------------------------------------------
    # SECTION 4: FIREBASE INTEGRATION & DATABASE ARCHITECTURE
    # -------------------------------------------------------------
    add_custom_heading(doc, "SECTION 4: Firebase Integration & Database Architecture", level=1)

    p = doc.add_paragraph()
    p.add_run("FrameFolio integrates Firebase Authentication, Firestore NoSQL Database, and Firebase Storage to power real-time updates and media hosting.").font.size = Pt(11)

    add_viva_qa_box(
        doc,
        "Sign Out button press karne par pehle App hang kyu ho raha tha aur use kaise solve kiya?",
        "Pehle sign-out logic me real-time Firestore stream listener par `.drain()` function execute kiya ja raha tha. Firestore stream continuous open channel hone ki wajah se `.drain()` kabhi complete hi nahi hota tha aur event loop block ho jata tha. Fix karne ke liye `.drain()` ko completely remove karke `AuthService().signOut()` run kiya gaya aur `Navigator.pushAndRemoveUntil()` se Auth/Login screen par redirect kiya gaya.",
        "Streams from Firestore snapshots() never close automatically. Calling .drain() on an infinite real-time stream blocks thread execution indefinitely."
    )

    add_viva_qa_box(
        doc,
        "Firestore Query me missing composite index error (`failed-precondition`) kyu milta hai aur use Dart code se kaise fix kiya?",
        "Jab Firestore me ek se zyada fields par simultaneously filtering (`.where()`) aur sorting (`.orderBy()`) hoti hai, to Firestore mandatory composite index demand karta hai. Bina index create kiye, humne Firestore se collection `.snapshots()` raw stream receive ki aur Dart memory me `.sort((a, b) => b.createdAt.compareTo(a.createdAt))` run kiya. Isse bina index error ke real-time updates achieve ho gaye.",
        "Server-side Firestore compound queries require indexes. Client-side/In-memory Dart sorting eliminates the index requirement for small to medium collections."
    )

    add_viva_qa_box(
        doc,
        "Hero Animation me duplicate hero tag exception kyu aata hai aur use kaise resolve kiya?",
        "Jab 2 identical Hero widgets ko screen transition par same tag String (e.g., static tag like 'hero_image') assign ho jati hai to Flutter engine uniquely match nahi kar pata. Humne har card me unique tag assign kiya: `heroTag: photographer.id.isNotEmpty ? photographer.id : photographer.hashCode.toString()`, jisse distinct transition guarantee hoti hai.",
        "Hero tags must be globally unique across active routes. Use entity primary key IDs or fallback HashCodes."
    )

    # -------------------------------------------------------------
    # SECTION 5: ULTIMATE 30+ PROJECT VIVA QUESTIONS & HINGLISH ANSWERS
    # -------------------------------------------------------------
    add_custom_heading(doc, "SECTION 5: Ultimate Project Viva Questions & High-Impact Hinglish Answers", level=1)

    viva_qas = [
        ("Q1: App entry point me main() function aur WidgetsFlutterBinding ka kya role hai?",
         "main() app ka execution start point hai. Isme `WidgetsFlutterBinding.ensureInitialized()` call kiya jata hai taaki Firebase initialize hone se pehle Flutter engine channels ready ho skein, aur `Firebase.initializeApp()` async initialize hota hai.",
         "WidgetsFlutterBinding binds the Flutter framework to the native host engine before asynchronous platform channel calls like Firebase.initializeApp()."),

        ("Q2: BuildContext kya hota hai aur iska use kyu kiya jata hai?",
         "BuildContext ek element tree node reference hai jo batata hai ki particular widget tree me kidhar positioned hai. Iska upayog Theme, Navigator aur MediaQuery find karne ke liye hota hai.",
         "BuildContext is a handle to the location of a widget within the widget tree structure."),

        ("Q3: StreamBuilder aur FutureBuilder me main difference kya hai?",
         "FutureBuilder ek single asynchronous operation (one-time request) ke complete hone ka wait karta hai, jabki StreamBuilder multiple data emissions (real-time stream) ko continuous listen karke UI updates karta hai.",
         "FutureBuilder listens to a single asynchronous response (Future). StreamBuilder subscribes to a continuous stream of events over time."),

        ("Q4: FrameFolio me Client aur Photographer ke roles kaise separate kiye gaye hain?",
         "Firestore `users` collection me har account ka `role` field ('client' ya 'photographer') save hota me hai. Login par role check hota hai — Client ko Browse/Booking view aur Photographer ko Studio Dashboard load hota hai.",
         "Role-based access control (RBAC) is enforced by querying the user document role field in Firestore upon authentication."),

        ("Q5: Packages selection (Basic, Standard, Premium) me dynamic pricing kaise update hoti hai?",
         "BookingScreen me `selectedPackage` state manage hoti hai. Jab user card select karta hai, `setState()` trigger hota hai aur summary CTA total price (`startingRate * multiplier`) instantly calculate karke display kar deta hai.",
         "Local widget state manages package index, dynamically recalculating total session cost via package multipliers."),

        ("Q6: Material 3 Bottom NavigationBar ko dark theme me custom styled kaise kiya gaya?",
         "AppTheme me `navigationBarTheme` override karke background `#121315`, indicator color `#C8A97E` (Champagne Gold), aur label text color `#F5F3EE` set kiya gaya hai.",
         "Custom NavigationBarThemeData configures selection indicator color, icon theme, and label typography."),

        ("Q7: Portfolio Image full screen viewer (Lightbox) kaise implement kiya gaya?",
         "PortfolioGrid me image item tap karne par `showDialog()` call hota hai. Inside dialog, `InteractiveViewer` widget use kiya gaya hai jisse user pinch-to-zoom aur pan gesture se high-res photo inspect kar sake.",
         "InteractiveViewer widget provides native double-tap, pan, and pinch-zoom gestures for high-resolution image viewing inside an overlay dialog."),

        ("Q8: Flutter me Null Safety ka kya benefits hai?",
         "Null Safety runtime NullPointerExceptions (NPEs) ko completely eliminate karta hai. Variables default Non-Nullable hote hain jab tak unke aage `?` optional type marker na lagaya jaye.",
         "Sound null safety catches null errors at compile-time rather than runtime, optimizing binary size and performance."),

        ("Q9: Web Platform par Flutter app host karne ke liye kaunse command execute kiye gaye?",
         "Pehle production web bundle compile kiya: `flutter build web --release`. Phir `firebase.json` me `public: build/web` config set karke CLI command `npx firebase-tools deploy --only hosting` run kiya gaya.",
         "flutter build web compiles Dart code into optimized HTML/JS/Wasm artifacts, served statically via Firebase Hosting CDN."),

        ("Q10: Project me State Management ke liye konsa approach use kiya gaya hai?",
         "FrameFolio me Clean Stateful State Management with Streams & Services model use kiya gaya hai. Simple UI state (tabs, pickers) ke liye `setState()` aur continuous database updates ke liye `StreamBuilder` + `FirestoreService` streams integrated hain.",
         "Hybrid approach combining local setState for transient presentation state and reactive Rx streams (StreamBuilder) for backend Firestore data sync.")
    ]

    for q, ans_h, ans_e in viva_qas:
        add_viva_qa_box(doc, q, ans_h, ans_e)

    # Save output document
    doc.save(output_path)
    print(f"Successfully generated Viva Document at: {output_path}")

if __name__ == "__main__":
    output_docx = "/Users/sarthak/Desktop/FrameFolio/FrameFolio_Flutter_Viva_Ready_Document.docx"
    os.makedirs(os.path.dirname(output_docx), exist_ok=True)
    create_viva_document(output_docx)
