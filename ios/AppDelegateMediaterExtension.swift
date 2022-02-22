//
//  AppDelegateMediaterExtension.swift
//  ios
//
//  Created by Maarten Vergouwe on 19/01/2022.
//  Copyright © 2022 Givt. All rights reserved.
//

import Foundation

extension AppDelegate {
    func registerHandlers() {
        // -- DONATIONS
        Mediater.shared.registerHandler(handler: CreateDonationCommandHandler())
        Mediater.shared.registerPreProcessor(processor: CreateDonationCommandValidator())
        Mediater.shared.registerHandler(handler: DeleteDonationCommandHandler())
        Mediater.shared.registerHandler(handler: ExportDonationCommandHandler())
        Mediater.shared.registerHandler(handler: GetDonationsByIdsQueryHandler())
        Mediater.shared.registerHandler(handler: GetUserHasDonationsQueryHandler())
        
        // -- RECURRING DONATIONS
        Mediater.shared.registerHandler(handler: GetRecurringDonationsQueryHandler())
        Mediater.shared.registerPreProcessor(processor: CreateRecurringDonationCommandPreHandler())
        Mediater.shared.registerHandler(handler: CreateRecurringDonationCommandHandler())
        Mediater.shared.registerHandler(handler: CancelRecurringDonationCommandHandler())
        Mediater.shared.registerHandler(handler: GetRecurringDonationTurnsQueryHandler())
        //-- USER QUERIES
        Mediater.shared.registerHandler(handler: GetLocalUserConfigurationHandler())
        Mediater.shared.registerHandler(handler: GetCountryQueryHandler())
        Mediater.shared.registerHandler(handler: GetAccountsQueryHandler())
        
        
        //-- USER COMMANDS
        Mediater.shared.registerHandler(handler: RegisterUserCommandHandler())
        Mediater.shared.registerHandler(handler: RegisterCreditCardByTokenCommandHandler())
        
        // -- COLLECT GROUPS
        Mediater.shared.registerHandler(handler: GetCollectGroupsQueryHandler())
        Mediater.shared.registerPreProcessor(processor: GetCollectGroupsQueryPreProcessor())
        
        // -- NAVIGATION
        Mediater.shared.registerHandler(handler: BackToMainRouteHandler())
        Mediater.shared.registerHandler(handler: FinalizeGivingRouteHandler())
        Mediater.shared.registerHandler(handler: DestinationSelectedRouteHandler())
        Mediater.shared.registerHandler(handler: SetupRecurringDonationChooseDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: GoToChooseRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: BackToSetupRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: PopToRecurringDonationOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: BackToRecurringDonationOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: GoToPushNotificationViewRouteHandler())
        Mediater.shared.registerHandler(handler: DismissPushNotificationViewRouteHandler())
        Mediater.shared.registerHandler(handler: GoToAboutViewRouteHandler())
        Mediater.shared.registerHandler(handler: OpenRecurringDonationOverviewListRouteHandler())
        Mediater.shared.registerHandler(handler: OpenRecurringRuleDetailFromNotificationRouteHandler())
        Mediater.shared.registerHandler(handler: FromFirstToSecondRegistrationRouteHandler())

        
        //-- INFRA
        Mediater.shared.registerHandler(handler: NoInternetAlertHandler())
        Mediater.shared.registerHandler(handler: GoBackOneControllerRouteHandler())
        Mediater.shared.registerHandler(handler: OpenFeatureByIdRouteHandler())
        Mediater.shared.registerHandler(handler: ShowUpdateAlertHandler())

        //-- DISCOVER OR AMOUNT: ROUTES
        Mediater.shared.registerHandler(handler: BackToMainViewRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSelectDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSetupSingleDonationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenSetupRecurringDonationRouteHandler())
        Mediater.shared.registerHandler(handler: OpenSafariRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountBackToSelectDestinationRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenChangeAmountLimitRouteHandler())
        Mediater.shared.registerPreProcessor(processor: DiscoverOrAmountOpenChangeAmountLimitRoutePreHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenRecurringSuccessRouteHandler())
        Mediater.shared.registerHandler(handler: DiscoverOrAmountOpenOfflineSuccessRouteHandler())
        Mediater.shared.registerHandler(handler: GetAllDonationsQueryHandler())
        
        //-- BUDGET SCENE: ROUTES
        Mediater.shared.registerHandler(handler: OpenSummaryRouteHandler())
        Mediater.shared.registerHandler(handler: OpenGiveNowRouteHandler())
        Mediater.shared.registerHandler(handler: OpenExternalGivtsRouteHandler())
        Mediater.shared.registerHandler(handler: OpenGivingGoalRouteHandler())
        Mediater.shared.registerHandler(handler: GoBackToSummaryRouteHandler())
        Mediater.shared.registerHandler(handler: OpenYearlyOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: OpenYearlyOverviewRouteDetailHandler())
        Mediater.shared.registerHandler(handler: GoBackToYearlyOverviewRouteHandler())
        Mediater.shared.registerHandler(handler: GoBackFromGivingGoalWithReloadRouteHandler())
        
        //-- BUDGET SCENE: QUERYS
        Mediater.shared.registerHandler(handler: GetMonthlySummaryQueryHandler())
        Mediater.shared.registerHandler(handler: GetExternalMonthlySummaryQueryHandler())
        Mediater.shared.registerHandler(handler: GetAllExternalDonationsQueryHandler())

        //-- Budget External Donations
        Mediater.shared.registerHandler(handler: CreateExternalDonationCommandHandler())
        Mediater.shared.registerPreProcessor(processor: CreateExternalDonationCronGenerator())
        Mediater.shared.registerHandler(handler: UpdateExternalDonationCommandHandler())
        Mediater.shared.registerHandler(handler: DeleteExternalDonationCommandHandler())
        Mediater.shared.registerHandler(handler: DownloadSummaryCommandHandler())
        Mediater.shared.registerPreProcessor(processor: DownloadSummaryCommandPreHandler())
        
        //-- Giving Goal
        Mediater.shared.registerHandler(handler: CreateGivingGoalCommandHandler()) //-- Can use as an update aswell
        Mediater.shared.registerHandler(handler: GetGivingGoalQueryHandler())
        Mediater.shared.registerHandler(handler: DeleteGivingGoalCommandHandler())
        
        //-- Advertisements
        Mediater.shared.registerHandler(handler: GetAdvertismentListQueryHandler())
        Mediater.shared.registerHandler(handler: GetAdvertisementsLastDateQueryHandler())
        Mediater.shared.registerHandler(handler: ImportAdvertisementsCommandHandler())
        Mediater.shared.registerHandler(handler: GetRandomAdvertisementQueryHandler())
        
        //-- CollectGroups
        Mediater.shared.registerHandler(handler: GetCollectGroupsV2QueryHandler())
        
        
    }
}
