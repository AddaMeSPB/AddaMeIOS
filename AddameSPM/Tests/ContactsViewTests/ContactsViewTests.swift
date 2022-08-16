//
//  ContactsViewTests.swift
//  
//
//  Created by Saroar Khandoker on 10.09.2022.
//

import XCTest
import ComposableArchitecture
import HTTPRequestKit
import KeychainService
import AddaSharedModels
import Combine
import URLRouting
import InfoPlist
import ContactClient
import ContactClientLive
import CoreDataClient

@testable import ContactsView

class ContactsViewTests: XCTestCase {
    let scheduler = DispatchQueue.test

    // swiftlint:disable line_length
    let accessToken = """
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdGF0dXMiOjAsImV4cCI6MTY2MzMxMjg4NywiaWF0IjoxNjYyNzA4MDg3LCJ1c2VySWQiOiI2MzFhZTk3NzhhYTU4YWZjNDFmOGUyZjciLCJwaG9uZU51bWJlciI6Iis3OTIxODgyMTIxNyJ9.TPzMxIw_9tls89I6ez2gj8QYu9C1ktNM-4AZ6V-Vrt8
    """

    // swiftlint:disable line_length
    let  contacts = [
        "+79110325921", "+79218821217", "+79117577149", "+79818238523", "+8801916025663", "+8801622091922", "+8801715801429", "+79817423000", "+79522094541", "+79211804044", "+79112538324", "+79602475870", "+79645859157", "+79657678576", "+79119233967", "+4915772026155", "+79602391377", "+6581242365", "+8801912614155", "+79216548181", "+919412363585", "+79045182268", "+79500235929", "+79111496493", "+79052870466", "+79218680630", "+79046191591", "+79516447392", "+447932077266", "+79052513787", "+4793982486", "+8801911303312", "+8801611303312", "+4917627574729", "+79670577875", "+79096352155", "+8801710658279", "+8801920787892", "+8801715295644", "+8801939900440", "+79516770291", "+79522304754", "+79633411400", "+79112414496", "+79215948860", "+79522142945", "+79533660260", "+79523819808", "+79030923013", "+79992010781", "+79219332968", "+33634628424", "+33751048425", "+79522271426", "+79262544951", "+79643315522", "+79651135758", "+79775286139", "+6590552120", "+79046136821", "+33633784198", "+79522412495", "+79500167585", "+79500258089", "+79522272118", "+380933367980", "+79618005251", "+79602334250", "+79211110505", "+919158007879", "+79062495782", "+79217578190", "+79500383407", "+79110185888", "+79522178435", "+79211110500", "+79653634391", "+79633235059", "+79213919072", "+79013085909", "+79119252114", "+79095787755", "+79213369290", "+79313073916", "+79643283747", "+79643764917", "+8801730026196", "+8801917217821", "+8801715064199", "+79112197235", "+79052529179", "+79533732050", "+79313166003", "+79052126882", "+79213278776", "+79611488909", "+380632966821", "+919998030068", "+79217700770", "+380686022618", "+380632549855", "+380688665075", "+79516624475", "+79030981651", "+79046112904", "+79500327655", "+79052225981", "+79119689776", "+79643996904", "+79052529179", "+79522206248", "+79119074121", "+8801711127753", "+79046492457", "+79214459898", "+8801748916286", "+79817437309", "+79633428657", "+79119635181", "+79219512742", "+79818142483", "+79214041981", "+79062724395", "+4746349639", "+79818960146", "+79500334344", "+79522424721", "+79500071554", "+79217776483", "+8801827211335", "+8801713076355", "+79052233534", "+8801814222375", "+79626858826", "+79312004416", "+79046305462", "+79633295084", "+79085151672", "+79046191591", "+79218680630", "+79522616931", "+79533522571", "+79657639204", "+79110017095", "+79218980128", "+79824806755", "+79052120491", "+46735036058", "+79627227977", "+8801680038914", "+79112414496", "+8801819118753", "+4793982486", "+79533504737", "+79811399430", "+79052870476", "+79522270139", "+79533504737", "+79522170029", "+79045171151", "+79117449024", "+79516520364", "+8801673949463", "+79500010039", "+8801912526846", "+8801646313059", "+8801859538004", "+79052225981", "+96899015826", "+60167318837", "+8801712511090", "+79110000308", "+79516755645", "+380636254794", "+79500327560", "+79214317643", "+79516602863", "+79817149001", "+79219304896", "+79052757610", "+79062567829", "+79650452155", "+919158007879", "+8801670852658", "+8801911005974", "+79117947821", "+79052160271", "+8801680038914", "+79818610107", "+79112951980", "+79811203431", "+79500327560", "+79522281462", "+8801912236582", "+79219307955", "+79818925143", "+79522484817", "+79650689676", "+79312656886", "+79522330781", "+8801914156883", "+79119389263", "+79523693230", "+79035132018", "+8801726271659", "+79213652860", "+79052870438", "+79516726325", "+79111206434", "+79219257341", "+79647609491", "+79082940022", "+79112250254", "+8801712032693", "+79111245036", "+4791113006", "+79288515679", "+380632966821", "+79818567491", "+79218977762", "+79291044783", "+79052687991", "+79672146600", "+919878215266", "+48662233778", "+79215574350", "+79213246639", "+79112443340", "+79112736476", "+79608453636", "+79265444869", "+79062645805", "+79817597803", "+79685757691", "+79516447392", "+4915210582723", "+79217683753", "+79219257641", "+380688665075", "+380688665075", "+79213172759", "+79210907003", "+79213632550", "+79118119433", "+79219310200", "+79046100307", "+79697297641", "+79217979793", "+79522735476", "+79500276212", "+79312113396", "+79219626682", "+79516636889", "+79811852983", "+79112283881", "+79819467606", "+79216547602", "+79046047626", "+79817849636", "+79219177982", "+79315426759", "+919600303113", "+79119194487", "+79112277979", "+79526655163", "+79533648086", "+79522342742", "+919321537565", "+639080313166", "+33661735367", "+8801850930655", "+79312097728", "+79219177982", "+79215598483", "+923425210009", "+8801622835357", "+8801622835357", "+79219243585", "+79043366368", "+79213903217", "+79219280460", "+79650659516", "+8801552370761", "+79523512025", "+8801682339862", "+380673087718", "+919665606531", "+79650366504", "+79312883836", "+79516605564", "+8801710828452", "+79243899316", "+79627079298", "+972526799743", "+972526799743", "+79112629111", "+79112629111", "+79110986130", "+79117342694", "+79516605564", "+79211882693", "+79219310200", "+79627079298", "+79118437220", "+79117533587", "+79533747560", "+79516669159", "+79992364996", "+79213924786", "+79523852939", "+79062261194", "+79502276731", "+79516686032", "+79500430981", "+79774431767", "+79779496448", "+79817584535", "+79119164762", "+79110836685", "+79811718016", "+79819791164", "+79313638017", "+79675911981", "+79219280460", "+5584994613227", "+79219429368", "+79117266686", "+79119021653", "+37125875720", "+79110891581", "+79118437220", "+79052597075", "+79817974290", "+60107021521", "+60107021521", "+79111528580", "+79112344337", "+79112195316", "+79523570120", "+79817178521", "+917498144471", "+79052838280", "+79516856134", "+79216374571", "+79117758425", "+79817234001", "+79218964982", "+79111607133", "+8801712607756", "+601128984526", "+601121753943", "+79522297095", "+79533430501", "+79111743954", "+79062264191", "+79118221726", "+79312883836", "+79602327686", "+79214139945", "+79500351441", "+79111743954", "+8801677511288", "+79062438177", "+79219860318", "+79771232686", "+971568765632", "+919850459381", "+79211878961", "+79627079298", "+79219243585", "+79117434812", "+79992127735", "+393273930270", "+79675115106", "+79046310888", "+79500010039", "+79526655163", "+79213952852", "+79119021653", "+971528387450", "+79111554929", "+79650791200", "+8801756039385", "+79256787966", "+8801911225556", "+8801817602209", "+8801773187108", "+8801711263714", "+8801912841956", "+8801757806272", "+8801715693911", "+8801998337789", "+8801755400630", "+8801623205084", "+966578514976", "+8801401999393", "+8801943910213", "+8801670100258", "+8801712844377", "+380671550707", "+79243899316", "+79516409480", "+380939278575", "+79117037561", "+8801989368315", "+79119994786", "+79213729226", "+79111801869", "+79216548181", "+79817597803", "+79131991854", "+79500003768", "+79291029399", "+79119351688", "+8801717806563", "+79650366503", "+8801913998694", "+79045119864", "+79203162974", "+79206649078", "+79602305310", "+79319626595", "+212611209929", "+212645259555", "+212663177614", "+420777807723", "+79117925266", "+79117925266", "+31642018178", "+79117748407", "+79117748407", "+79614008521", "+79312276360", "+919610993993", "+919415047613", "+79818117659", "+79110806870", "+79110806870", "+79818117659", "+79995256095", "+79101162873", "+8801989368315", "+79217977923", "+79312278076", "+48882026913", "+818034564782", "+818013310249", "+8801704130847", "+8801711148241", "+8801788990677", "+8801766152429", "+919878215266", "+601128984526", "+8801857545454", "+5549999307682", "+8801934841958", "+8801917714450", "+48884124375", "+41792568268", "+48537619051", "+79111105833", "+79817181002", "+79213638411", "+917526924247", "+972547502570", "+358400170184", "+420734157987", "+79967814319", "+79218821219", "+79052771794", "+380506673340", "+79522166520", "+79117051031", "+79214302781", "+79991111111", "+33699854083", "+8801710368219", "+919898962255", "+79218821214", "+79602598811", "+79253053610", "+60162979784", "+79522606344", "+37120040964", "+79688926727", "+79062517483", "+79811541411", "+351920060556", "+34679773955", "+79602825451", "+79916747026", "+79052024686", "+79531663422", "+8801852478099", "+79110303322", "+79110078222", "+8801711458437", "+8801611458437", "+79650035008", "+998934433707", "+375292823302", "+79052262767", "+79621941844", "+8801675753137", "+8801937975376", "+8801910570689", "+8801674980196", "+79052069881", "+84856327380", "+375293573379", "+46738326662", "+79117916968", "+79111476652", "+79118224586", "+79772818367", "+79213104806", "+33769845988", "+491624194006", "+79253053610", "+998903744554", "+8801916025663", "+79218821218", "+79250856577", "+79296531296", "+79859234864", "+8801823410353", "+8801674980196", "+8801729627955", "+8801627093943", "+79859234863", "+79052713535", "+79215749694", "+4917659031411", "+79117043049", "+79203326529", "+79217573725", "+79268963256", "+79282453145", "+79633451025", "+79164438418", "+79115418801", "+79164330301", "+79219056487", "+79203319536", "+79219948211", "+79516879207", "+79261993069", "+79213180441", "+79219112733", "+79046054116", "+79520956100", "+79151791781", "+79046452256", "+79117842230", "+79990053222", "+79516460997", "+79112993908", "+79030004402", "+79210900626", "+79319840500", "+79531723173", "+79119268855", "+79522098474", "+79998263668", "+79031891799", "+79214189818", "+79117355727", "+8801726908457", "+79046369098", "+79217906226", "+79897313669", "+79296157031", "+79252681040", "+79163948374", "+8801908784663", "+8801726979897", "+79119247272", "+998995720789", "+79119400815", "+79166943215", "+79024872555", "+79859615880", "+79855351179", "+79919329710", "+79919216896", "+79153075443", "+79203057912", "+79605874681", "+905436186978", "+6282117685005", "+79277030064", "+79657524370", "+79169367619", "+79516800728", "+905367195512", "+79213497735", "+79215685319", "+79046141619", "+79119994786", "+79650380312", "+79217941491", "+79214479338", "+79111502151", "+79516432768", "+79216347911", "+79119994660", "+79269197556", "+79269197557", "+79818038335"]

    func testGetContacts() async throws {

        let uniqNumbers = Set(contacts)

        let state = ContactsState()

        let environment = ContactsEnvironment(
            coreDataClient: .init(contactClient: .live(api: .build)),
            contactClient: .live(api: .build),
            backgroundQueue: scheduler.eraseToAnyScheduler(),
            mainQueue: scheduler.eraseToAnyScheduler()
        )

        let store = TestStore(
          initialState: state,
          reducer: contactsReducer,
          environment: environment
        )

        await store.send(.contactsAuthorizationStatus(.authorized))

        await store.send(.contactsResponse(.success(ContactOutPut.contactsMock))) {
            let contactRowStates = $0.contacts.map { _ in ContactRowState(contact: ContactOutPut.contact1) }
            $0.contacts = .init(uniqueElements: contactRowStates)
        }

        XCTAssertEqual(0, 0)
    }
}
