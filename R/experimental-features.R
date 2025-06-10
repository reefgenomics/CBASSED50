#' @title Experimental Features for CBASS Dataset Analysis
#' @description This script contains functions for processing and analyzing CBASS datasets, including fitting dose-response models, calculating effective doses (ED5, ED50, ED95), and plotting results.
#'
#' Process the dataset by preprocessing, validating, and defining grouping properties.
#'
#' @param cbass_dataset A data frame containing the dataset to be processed.
#' @param grouping_properties A character vector of column names to be used for grouping. Default: c("Site", "Condition", "Species", "Timepoint").
#'
#' @return A processed data frame with the grouping property defined.
#'
#' @import dplyr
#'
#' @examples
#' # Example dataset
#' data(cbass_dataset)
#'
#' # Example grouping properties
#' grouping_properties <- c("Site", "Condition", "Species", "Timepoint")
#'
#' # Process the dataset
#' processed_dataset <- process_dataset(cbass_dataset, grouping_properties)
#' @export
process_dataset <- function(cbass_dataset, grouping_properties) {
    cbass_dataset <- preprocess_dataset(cbass_dataset)
    validate_cbass_dataset(cbass_dataset)

    cbass_dataset <- define_grouping_property(cbass_dataset, grouping_properties) %>%
    mutate(GroupingProperty = paste(GroupingProperty, Genotype, sep = "_"))

    return(cbass_dataset)
}

#' Calculate ED5, ED50, and ED95 values for all samples in the dataset.
#'
#' @param cbass_dataset A data frame containing the dataset to be processed.
#' @param grouping_properties A character vector of column names to be used for grouping. Default: c("Site", "Condition", "Species", "Timepoint").
#' @param drm_formula A formula object specifying the dose-response model. Default: "Pam_value ~ Temperature".
#'
#' @return A data frame with ED5, ED50, and ED95 values for each grouping property.
#'
#' @import dplyr
#'
#' @examples
#' # Example dataset
#' data(cbass_dataset)
#'
#' # Extract the ED5, ED50, and ED95 values as a data frame
#' eds_df <- calculate_eds(cbass_dataset)
#' @export
calculate_eds <- function(cbass_dataset, grouping_properties = c("Site", "Condition", "Species", "Timepoint"), drm_formula = "Pam_value ~ Temperature") {
    processed_dataset <- process_dataset(cbass_dataset, grouping_properties)

    models <- fit_drms(processed_dataset, grouping_properties, drm_formula, is_curveid = TRUE)

    eds <- get_all_eds_by_grouping_property(models)
    # processed_dataset <- define_grouping_property(processed_dataset, grouping_properties) %>%
    #     mutate(GroupingProperty = paste(GroupingProperty, Genotype, sep = "_"))
    eds_df <- left_join(eds, processed_dataset, by = "GroupingProperty") %>%
        select(names(eds), all_of(grouping_properties)) %>%
        distinct()

    return(eds_df)
}

#' Fit dose-response models and calculate summary statistics for ED5, ED50, and ED95 values.
#'
#' @param cbass_dataset A data frame containing the dataset to be processed.
#' @param grouping_properties A character vector of column names to be used for grouping. Default: c("Site", "Condition", "Species", "Timepoint").
#' @param drm_formula A formula object specifying the dose-response model. Default: "Pam_value ~ Temperature".
#'
#' @return A data frame with summary statistics for ED5, ED50, and ED95 values.
#'
#' @import dplyr
#' @importFrom stats qt sd
#' 
#' @examples
#' # Example dataset
#' data(cbass_dataset)
#'
#' # Example grouping properties
#' grouping_properties <- c("Site", "Condition", "Species", "Timepoint")
#'
#' # Extract the ED5, ED50, and ED95 values as a data frame
#' fitted_edss_df <- fit_curve_eds(cbass_dataset, grouping_properties)
#' @export
fit_curve_eds <- function(cbass_dataset, grouping_properties = c("Site", "Condition", "Species", "Timepoint"), drm_formula = "Pam_value ~ Temperature") {
    processed_dataset <- process_dataset(cbass_dataset, grouping_properties)

    summary_eds_df <- calculate_eds(processed_dataset, grouping_properties, drm_formula) %>%
        group_by(across(all_of(grouping_properties))) %>%
        summarise(Mean_ED5 = mean(ED5),
            SD_ED5 = sd(ED5),
            SE_ED5 = sd(ED5) / sqrt(n()),
            Conf_Int_5 = qt(0.975, df = n() - 1) * SE_ED5,
            Mean_ED50 = mean(ED50),
            SD_ED50 = sd(ED50),
            SE_ED50 = sd(ED50) / sqrt(n()),
            Conf_Int_50 = qt(0.975, df = n() - 1) * SE_ED50,
            Mean_ED95 = mean(ED95),
            SD_ED95 = sd(ED95),
            SE_ED95 = sd(ED95) / sqrt(n()),
            Conf_Int_95 = qt(0.975, df = n() - 1) * SE_ED95) %>%
                mutate(across(c(Mean_ED50, SD_ED50, SE_ED50,
                    Mean_ED5, SD_ED5, SE_ED5,
                    Mean_ED95, SD_ED95, SE_ED95,
                    Conf_Int_5, Conf_Int_50, Conf_Int_95), ~ round(., 2)))

    return(summary_eds_df)
}

#' Plot a boxplot of ED50 values for different species and conditions.
#'
#' @param cbass_dataset A data frame containing the dataset to be processed.
#' @param grouping_properties A character vector of column names to be used for grouping. Default: c("Site", "Condition", "Species", "Timepoint")
#' @param drm_formula A formula object specifying the dose-response model. Default: "Pam_value ~ Temperature".
#' @param Condition A character string specifying the condition to be used for coloring the plot. Default: "Condition".
#' @param faceting A formula specifying the faceting of the plot. Default: "~ Site".
#' @param size_text Default: 12. A formula specifying the faceting of the plot.
#' @param size_points Default: 2. A formula specifying the faceting of the plot.
#'
#' @return A ggplot object representing the boxplot of ED50 values.
#'
#' @import dplyr ggplot2
#'
#' @examples
#' # Example dataset
#' data(cbass_dataset)
#'
#' # Example grouping properties
#' grouping_properties <- c("Site", "Condition", "Species", "Timepoint")
#'
#' # Make ggplot object
#' boxplot_ED50 <- plot_ED50_box(cbass_dataset)
#'
#' @export
plot_ED50_box <- function(cbass_dataset, grouping_properties = c("Site", "Condition", "Species", "Timepoint"), drm_formula = "Pam_value ~ Temperature", Condition = "Condition", faceting = "~ Site", size_text = 12, size_points = 2) {
        processed_dataset <- process_dataset(cbass_dataset, grouping_properties)
        eds_boxplot <- calculate_eds(processed_dataset, grouping_properties, drm_formula) %>% ggplot(
        aes(x = Species, y = ED50, color = Condition)) +
        geom_boxplot(linewidth = size_points / 2) + 
        stat_summary(
            fun = mean,
            geom = "text",
            aes(label = round(after_stat(y), 2)), show.legend = F,
            position = position_dodge(width = 0.75),
            vjust = -1,
            size = size_points * 2
        ) +
        facet_grid(as.formula(faceting)) +
            ylab("ED50s - Temperatures [\u00B0C]") +
            scale_color_brewer(palette = "Set2") +
        theme_minimal(base_size = size_text)

    return(eds_boxplot)
}

#' Plot an exploratory temperature response curve.
#'
#' @param cbass_dataset A data frame containing the dataset to be processed.
#' @param grouping_properties A character vector of column names to be used for grouping. Default: c("Site", "Condition", "Species", "Timepoint").
#' @param faceting A formula specifying the faceting of the plot. Default: "Species ~ Site ~ Condition".
#' @param size_text Default: 12. A formula specifying the faceting of the plot.
#' @param size_points Default: 2. A formula specifying the faceting of the plot.
#'
#' @return A ggplot object representing the temperature response curve.
#'
#' @import dplyr ggplot2 drc
#' 
#' @examples
#' # Load example dataset
#' data(cbass_dataset)
#' 
#' # Create an exploratory temperature response curve
#' exploratory_curve <- exploratory_tr_curve(cbass_dataset)
#' @export
exploratory_tr_curve <- function(cbass_dataset, grouping_properties = c("Site", "Condition", "Species", "Timepoint"), faceting = "Species ~ Site ~ Condition", size_text = 12, size_points = 2) {
    processed_dataset <- process_dataset(cbass_dataset, grouping_properties)

        exploratory_curve <- ggplot(data = processed_dataset,
            aes(x = Temperature,
                y = Pam_value,
                group = GroupingProperty,
                color = Genotype)) +
        geom_smooth(
            method = drc::drm,
            method.args = list(
                fct = drc::LL.3()),
            se = FALSE,
            linewidth = (size_points/2)
        ) +
        geom_point(size = size_points) +
        facet_grid(as.formula(faceting)) +
        theme_minimal(base_size = size_text) +
        scale_color_brewer(palette = "Paired") # Colorblind-friendly palette

    return(exploratory_curve)
}


#' Plot the model curve with predicted PAM values and confidence intervals.
#'
#' @param cbass_dataset A data frame containing the dataset to be processed.
#' @param grouping_properties A character vector of column names to be used for grouping. Default: c("Site", "Condition", "Species", "Timepoint").
#' @param drm_formula A formula object specifying the dose-response model. Default: "Pam_value ~ Temperature".
#' @param faceting_model A formula specifying the faceting of the plot. Default: "Species ~ Site ~ Condition".
#' @param size_text Default: 12. A formula specifying the faceting of the plot.
#' @param size_points Default: 2. A formula specifying the faceting of the plot.
#' 
#' @return A ggplot object representing the model curve with predicted PAM values.
#'
#' @import dplyr ggplot2 drc
#'
#' @examples
#' data(cbass_dataset)
#'
#' model_curve_plot <- plot_model_curve(cbass_dataset)
#' @export
plot_model_curve <- function(cbass_dataset, grouping_properties = c("Site", "Condition", "Species", "Timepoint"), drm_formula = "Pam_value ~ Temperature", faceting_model = "Species ~ Site ~ Condition", size_text = 12, size_points = 2) {
    processed_dataset <- process_dataset(cbass_dataset, grouping_properties)

    models <- fit_drms(processed_dataset, grouping_properties, drm_formula, is_curveid = FALSE)
    temp_ranges <- define_temperature_ranges(processed_dataset$Temperature, n = 100)
    predictions <- get_predicted_pam_values(models, temp_ranges)

    predictions_df <- left_join(predictions,
            define_grouping_property(processed_dataset, grouping_properties) %>% 
                select(c(all_of(grouping_properties), GroupingProperty)),
                    by = "GroupingProperty",
                    relationship = "many-to-many") %>%
                    distinct() %>%
        left_join(fit_curve_eds(processed_dataset, grouping_properties, drm_formula), by = grouping_properties)

    tempresp_curve <- ggplot(predictions_df,
        aes(x = Temperature,
            y = PredictedPAM,
            group = GroupingProperty,
            color = Condition)) +
    geom_line(linewidth = (size_points/2)) +
    geom_ribbon(aes(ymin = Upper,
                    ymax = Lower,
                    fill = Condition),
                alpha = 0.2,
                linetype = "dashed",
                linewidth = (size_points/2)) +
    geom_segment(aes(x = Mean_ED5,
                    y = 0,
                    xend = Mean_ED5,
                    yend = max(Upper)),
                linetype = 3) +
    geom_text(mapping = aes(x = Mean_ED5,
                            y = max(Upper) + 0.12,
                            label = round(Mean_ED5, 2)),
                size = size_text/2, angle = 90, check_overlap = T) +
    geom_segment(aes(x = Mean_ED50,
                    y = 0,
                    xend = Mean_ED50,
                    yend = max(Upper)),
                linetype = 3) +
    geom_text(mapping = aes(x = Mean_ED50,
                            y = max(Upper) + 0.12,
                            label = round(Mean_ED50, 2)),
                size = size_text/2, angle = 90, check_overlap = T) +
    geom_segment(aes(x = Mean_ED95,
                    y = 0,
                    xend = Mean_ED95,
                    yend = max(Upper)),
                linetype = 3) +
    geom_text(mapping = aes(x = Mean_ED95,
                            y = max(Upper) + 0.12,
                            label = round(Mean_ED95, 2)),
                size = size_text/2, angle = 90, check_overlap = T) +
    facet_grid(as.formula(faceting_model)) +
    # To add the real PAM and compare with predicted values
    geom_point(data = processed_dataset,
                aes(x = Temperature,
                    y = Pam_value)) +
                    xlab("Temperature [\u00B0C]") +
    scale_y_continuous(expand = c(0, 0.2)) +
    theme_minimal(base_size = size_text)
    
    return(tempresp_curve)
}
#TODO: add break points with calculated differnce of temperature #X = MMM ;+6 ; +8 ; +10
#TODO: make the graph interactive so that clicking tells you the value of the point (temperature)
