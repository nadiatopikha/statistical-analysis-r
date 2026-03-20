# Check dataset for missing values
check_missing_values <- function(data) {
  missing_values <- sum(is.na(data))
  
  if (missing_values > 0) {
    stop(paste("Detected", missing_values, "missing or invalid values in the dataset."))
  }
  
  return(TRUE)
}

# Calculate main descriptive statistics
calculate_all_stats <- function(data) {
  data <- na.omit(data)
  uniqv <- unique(data)
  
  sample_mean <- mean(data)
  sample_median <- median(data)
  sample_mode <- uniqv[which.max(tabulate(match(data, uniqv)))]
  sample_variance <- var(data)
  sample_sd <- sd(data)
  
  return(list(
    mean = sample_mean,
    median = sample_median,
    mode = sample_mode,
    variance = sample_variance,
    sd = sample_sd
  ))
}

# Calculate confidence intervals for mean and variance
calculate_confidence_interval <- function(data, confidence_level = 0.95) {
  data <- na.omit(data)
  n <- length(data)
  sample_mean <- mean(data)
  sample_variance <- var(data)
  sample_sd <- sd(data)
  
  alpha <- 1 - confidence_level
  
  # Confidence interval for mean
  t_critical <- qt(1 - alpha / 2, df = n - 1)
  margin_of_error <- t_critical * sample_sd / sqrt(n)
  
  lower_bound_mean <- sample_mean - margin_of_error
  upper_bound_mean <- sample_mean + margin_of_error
  
  # Confidence interval for variance
  chi_squared_lower <- qchisq(alpha / 2, df = n - 1)
  chi_squared_upper <- qchisq(1 - alpha / 2, df = n - 1)
  
  lower_bound_variance <- (n - 1) * sample_variance / chi_squared_upper
  upper_bound_variance <- (n - 1) * sample_variance / chi_squared_lower
  
  return(list(
    lower_bound_mean = lower_bound_mean,
    upper_bound_mean = upper_bound_mean,
    lower_bound_variance = lower_bound_variance,
    upper_bound_variance = upper_bound_variance
  ))
}

# Plot histogram with density curve
plot_distribution <- function(data, title = "Sample Histogram") {
  hist(data,
       main = title,
       xlab = "Values",
       ylab = "Frequency",
       col = "lightgreen",
       border = "black",
       freq = FALSE)
  
  lines(density(data), col = "red", lwd = 2)
}

# Plot empirical cumulative distribution function
plot_ecdf <- function(data) {
  plot(ecdf(data),
       main = "Empirical Distribution Function",
       xlab = "Values",
       ylab = "Cumulative Probability",
       col = "blue",
       verticals = TRUE,
       do.points = FALSE)
}

# Perform Student's t-test
t_test_for_equality_of_means <- function(data1, data2, alternative = "two.sided", confidence_level = 0.95) {
  t_test <- t.test(data1, data2, alternative = alternative, conf.level = confidence_level)
  
  return(list(
    p_value = t_test$p.value,
    confidence_interval = t_test$conf.int,
    estimate = t_test$estimate,
    alternative = t_test$alternative
  ))
}

# Perform Mann-Whitney U test
wilcoxon_mann_whitney_test <- function(data1, data2, alternative = "two.sided") {
  wilcox_test <- wilcox.test(data1, data2, alternative = alternative)
  
  return(list(
    p_value = wilcox_test$p.value,
    alternative = wilcox_test$alternative,
    statistic = wilcox_test$statistic
  ))
}

# Remove outliers
clean_data <- function(data, method = "IQR", threshold = 3) {
  if (method == "IQR") {
    q1 <- quantile(data, 0.25, na.rm = TRUE)
    q3 <- quantile(data, 0.75, na.rm = TRUE)
    iqr <- IQR(data, na.rm = TRUE)
    
    lower_bound <- q1 - 1.5 * iqr
    upper_bound <- q3 + 1.5 * iqr
    
    outliers <- data[data < lower_bound | data > upper_bound]
    cleaned_data <- data[data >= lower_bound & data <= upper_bound]
    
  } else if (method == "Z-score") {
    z_scores <- (data - mean(data, na.rm = TRUE)) / sd(data, na.rm = TRUE)
    outliers <- data[abs(z_scores) > threshold]
    cleaned_data <- data[abs(z_scores) <= threshold]
    
  } else {
    stop("Unsupported method")
  }
  
  return(list(
    cleaned_data = cleaned_data,
    outliers = outliers
  ))
}

# Shift transformation
shift_transform <- function(data, shift) {
  return(data + shift)
}

# Standardization
standardize_transform <- function(data) {
  return(as.numeric(scale(data)))
}

# Log transformation
log_transform <- function(data) {
  if (any(data <= 0, na.rm = TRUE)) {
    min_val <- min(data, na.rm = TRUE)
    data <- data + abs(min_val) + 0.1
  }
  
  return(log(data))
}

# =========================
# Main program
# =========================

# Load first dataset
data <- scan(file = file.choose(), what = numeric(), na.strings = "", strip.white = TRUE)
check_missing_values(data)

stats <- calculate_all_stats(data)
cat("Mean:", stats$mean, "\n")
cat("Median:", stats$median, "\n")
cat("Mode:", stats$mode, "\n")
cat("Variance:", stats$variance, "\n")
cat("Standard deviation:", stats$sd, "\n")

ci <- calculate_confidence_interval(data)
cat("Confidence interval for mean:", ci$lower_bound_mean, ",", ci$upper_bound_mean, "\n")
cat("Confidence interval for variance:", ci$lower_bound_variance, ",", ci$upper_bound_variance, "\n")

plot_distribution(data, "Histogram of Raw Data")
dev.new()
plot_ecdf(data)

# Load second dataset
data2 <- scan(file = file.choose(), what = numeric(), na.strings = "", strip.white = TRUE)
check_missing_values(data2)

# Student's t-test
t_results <- t_test_for_equality_of_means(data, data2)
cat("Student's t-test p-value:", t_results$p_value, "\n")
cat("Confidence interval:", t_results$confidence_interval[1], "-", t_results$confidence_interval[2], "\n")
cat("Estimated means:", t_results$estimate, "\n")
cat("Alternative hypothesis:", t_results$alternative, "\n")

# Mann-Whitney U test
w_results <- wilcoxon_mann_whitney_test(data, data2)
cat("Mann-Whitney U test p-value:", w_results$p_value, "\n")
cat("Alternative hypothesis:", w_results$alternative, "\n")
cat("U statistic:", w_results$statistic, "\n")

# Remove outliers
clean_results <- clean_data(data, method = "IQR")
cat("Data without outliers:", clean_results$cleaned_data, "\n")
cat("Outliers:", clean_results$outliers, "\n")

data_cleaned <- clean_results$cleaned_data
data_shifted <- shift_transform(data, 10.1)
data_standardized <- standardize_transform(data)
data_logged <- log_transform(data)

plot_distribution(data_cleaned, "Histogram of Cleaned Data")
dev.new()
plot_distribution(data_shifted, "Histogram After Shift")
dev.new()
plot_distribution(data_standardized, "Histogram After Standardization")
dev.new()
plot_distribution(data_logged, "Histogram After Log Transformation")