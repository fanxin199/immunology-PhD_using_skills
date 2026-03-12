# ============================================================
# BioViz Pro - Kaplan-Meier 生存曲线模板
# 用途：展示不同组别的生存分析结果
# ============================================================

library(survival)
library(survminer)
library(ggsci)
library(svglite)

# 发表级保存函数
save_publication_figure <- function(plot_obj, filename, width = 8, height = 6, 
                                     dpi = 300, output_dir = "figures") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
  ggsave(file.path(output_dir, paste0(filename, ".svg")),
         plot_obj, width = width, height = height, device = svglite::svglite)
  ggsave(file.path(output_dir, paste0(filename, ".png")),
         plot_obj, width = width, height = height, dpi = dpi, bg = "white")
  ggsave(file.path(output_dir, paste0(filename, ".pdf")),
         plot_obj, width = width, height = height, device = cairo_pdf)
  message(paste0("✅ 图形已保存: ", output_dir, "/", filename))
}

# 模拟生存数据
set.seed(42)
n <- 100
surv_data <- data.frame(
  time = c(rexp(50, 0.02), rexp(50, 0.05)),  # 生存时间
  status = rbinom(n, 1, 0.7),                 # 事件状态（1=死亡/事件）
  group = rep(c("Low Risk", "High Risk"), each = 50),
  age = round(rnorm(n, 60, 10)),
  sex = sample(c("Male", "Female"), n, replace = TRUE)
)

# 创建生存对象
surv_obj <- Surv(time = surv_data$time, event = surv_data$status)

# 拟合 Kaplan-Meier 模型
fit <- survfit(surv_obj ~ group, data = surv_data)

# NPG 配色
npg_colors <- pal_npg("nrc")(10)

# 绑制生存曲线 - Nature 风格
km_plot <- ggsurvplot(
  fit, data = surv_data,
  
  # 配色
  palette = c(npg_colors[1], npg_colors[4]),  # 红色高风险，蓝色低风险
  
  # 置信区间
  conf.int = TRUE,
  conf.int.alpha = 0.15,
  
  # 风险表
  risk.table = TRUE,
  risk.table.col = "strata",
  risk.table.height = 0.25,
  risk.table.y.text = FALSE,
  
  # 删失标记
  censor.shape = "|",
  censor.size = 3,
  
  # p值和风险比
  pval = TRUE,
  pval.coord = c(0, 0.15),
  pval.size = 4,
  
  # 图例
  legend.title = "Risk Group",
  legend.labs = c("High Risk", "Low Risk"),
  legend = c(0.8, 0.9),
  
  # 标题和标签
  title = "Kaplan-Meier Survival Curve",
  xlab = "Time (months)",
  ylab = "Survival Probability",
  
  # 主题
  ggtheme = theme_pubr(base_size = 12),
  font.main = c(14, "bold"),
  font.x = c(12, "bold"),
  font.y = c(12, "bold"),
  font.tickslab = 10
)

# 保存（survminer 需要特殊处理）
if (!dir.exists("figures")) dir.create("figures")
pdf("figures/survival_curve_NPG.pdf", width = 8, height = 7)
print(km_plot)
dev.off()

png("figures/survival_curve_NPG.png", width = 8, height = 7, units = "in", res = 300)
print(km_plot)
dev.off()

svglite::svglite("figures/survival_curve_NPG.svg", width = 8, height = 7)
print(km_plot)
dev.off()

message("✅ 生存曲线已保存至 figures/survival_curve_NPG")

# Lancet 风格
lancet_colors <- pal_lancet("lanonc")(9)
km_lancet <- ggsurvplot(
  fit, data = surv_data,
  palette = c(lancet_colors[1], lancet_colors[2]),
  conf.int = TRUE, risk.table = TRUE,
  pval = TRUE, legend.title = "Risk Group",
  title = "Survival Curve (Lancet Style)",
  ggtheme = theme_pubr()
)

pdf("figures/survival_curve_Lancet.pdf", width = 8, height = 7)
print(km_lancet)
dev.off()

message("
╔════════════════════════════════════════════════════════════╗
║  生存曲线绑制完成！                                        ║
║  输出：survival_curve_NPG.svg/png/pdf                      ║
╚════════════════════════════════════════════════════════════╝
")
