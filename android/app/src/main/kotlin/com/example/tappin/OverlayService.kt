package com.example.tappin

import android.animation.ValueAnimator
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.RectF
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.View
import android.view.WindowManager
import android.view.animation.LinearInterpolator
import androidx.core.app.NotificationCompat

private const val CHANNEL_ID = "overlay_service"
private const val NOTIFICATION_ID = 1001
private const val TAP_THRESHOLD_PX = 10
private const val COMPLETE_DISPLAY_MS = 2000L
private const val DEBOUNCE_MS = 500L
private const val SIZE_DP_INITIAL = 80
private const val SIZE_DP_MIN = 48
private const val SIZE_DP_MAX = 160

class OverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: OverlayButtonView
    private lateinit var layoutParams: WindowManager.LayoutParams
    private val mainHandler = Handler(Looper.getMainLooper())
    private var buttonSizePx = 0

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        buttonSizePx = dpToPx(SIZE_DP_INITIAL)
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
        addOverlayView()
    }

    private fun dpToPx(dp: Int): Int =
        (dp * resources.displayMetrics.density).toInt()

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "オーバーレイサービス",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification() = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("TapPin")
        .setContentText("オーバーレイボタン表示中")
        .setSmallIcon(android.R.drawable.ic_menu_mylocation)
        .setPriority(NotificationCompat.PRIORITY_LOW)
        .build()

    private fun addOverlayView() {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        layoutParams = WindowManager.LayoutParams(
            buttonSizePx,
            buttonSizePx,
            windowType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 100
            y = 300
        }

        overlayView = OverlayButtonView(this)
        overlayView.setOnTouchListener(OverlayTouchListener())
        windowManager.addView(overlayView, layoutParams)
    }

    private fun updateButtonSize() {
        layoutParams.width = buttonSizePx
        layoutParams.height = buttonSizePx
        windowManager.updateViewLayout(overlayView, layoutParams)
    }

    override fun onDestroy() {
        if (::overlayView.isInitialized) {
            overlayView.cleanup()
            windowManager.removeView(overlayView)
        }
        super.onDestroy()
    }

    enum class ButtonState { IDLE, RECORDING, COMPLETE }

    inner class OverlayButtonView(context: Context) : View(context) {

        init {
            // BlurMaskFilter の描画に必要
            setLayerType(LAYER_TYPE_SOFTWARE, null)
        }

        private val colorBlue = 0xFF1A73E8.toInt()
        private val colorBlueFaded = 0xFFADD8FF.toInt()
        private val colorGreen = 0xFF34A853.toInt()
        private val colorSurface = Color.WHITE

        private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = 0x28000000 }
        private val surfacePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = colorSurface }
        private val pinFillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = colorBlue }
        private val pinHolePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = colorSurface }
        private val spinnerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = colorBlue
            style = Paint.Style.STROKE
            strokeCap = Paint.Cap.ROUND
        }
        private val checkPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = colorGreen
            style = Paint.Style.STROKE
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
        }

        var state: ButtonState = ButtonState.IDLE
            set(value) {
                field = value
                when (value) {
                    ButtonState.IDLE -> {
                        pinFillPaint.color = colorBlue
                        rotateAnimator.cancel()
                        sweepAngle = 0f
                    }
                    ButtonState.RECORDING -> {
                        pinFillPaint.color = colorBlueFaded
                        rotateAnimator.start()
                    }
                    ButtonState.COMPLETE -> {
                        rotateAnimator.cancel()
                        sweepAngle = 0f
                    }
                }
                invalidate()
            }

        private var sweepAngle = 0f
        private val rotateAnimator = ValueAnimator.ofFloat(0f, 360f).apply {
            duration = 1000
            repeatCount = ValueAnimator.INFINITE
            interpolator = LinearInterpolator()
            addUpdateListener { sweepAngle = it.animatedValue as Float; invalidate() }
        }

        override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
            super.onSizeChanged(w, h, oldw, oldh)
            val r = minOf(w, h) / 2f * 0.80f
            shadowPaint.maskFilter = BlurMaskFilter(r * 0.28f, BlurMaskFilter.Blur.NORMAL)
        }

        fun cleanup() { rotateAnimator.cancel() }

        override fun onDraw(canvas: Canvas) {
            val cx = width / 2f
            val cy = height / 2f
            val r = minOf(width, height) / 2f * 0.80f

            // 影
            canvas.drawCircle(cx, cy + r * 0.18f, r * 0.96f, shadowPaint)
            // 白い円形ボタン
            canvas.drawCircle(cx, cy, r, surfacePaint)

            when (state) {
                ButtonState.IDLE -> drawPin(canvas, cx, cy, r)
                ButtonState.RECORDING -> {
                    drawPin(canvas, cx, cy, r)
                    drawSpinner(canvas, cx, cy, r)
                }
                ButtonState.COMPLETE -> drawCheckmark(canvas, cx, cy, r)
            }
        }

        private fun drawPin(canvas: Canvas, cx: Float, cy: Float, r: Float) {
            val size = r * 0.74f
            val headR = size * 0.34f
            val headY = cy - size * 0.10f
            val tipY = cy + size * 0.46f

            val path = Path().apply {
                moveTo(cx, tipY)
                arcTo(
                    RectF(cx - headR, headY - headR, cx + headR, headY + headR),
                    120f, 300f, false
                )
                lineTo(cx, tipY)
                close()
            }
            canvas.drawPath(path, pinFillPaint)
            // ピン頭の穴（白抜き）
            pinHolePaint.color = if (state == ButtonState.RECORDING) colorSurface else colorSurface
            canvas.drawCircle(cx, headY, headR * 0.36f, pinHolePaint)
        }

        private fun drawSpinner(canvas: Canvas, cx: Float, cy: Float, r: Float) {
            spinnerPaint.strokeWidth = r * 0.10f
            val spinR = r * 0.88f
            canvas.drawArc(
                RectF(cx - spinR, cy - spinR, cx + spinR, cy + spinR),
                sweepAngle, 260f, false, spinnerPaint
            )
        }

        private fun drawCheckmark(canvas: Canvas, cx: Float, cy: Float, r: Float) {
            checkPaint.strokeWidth = r * 0.13f
            val s = r * 0.44f
            val path = Path().apply {
                moveTo(cx - s, cy)
                lineTo(cx - s * 0.12f, cy + s * 0.70f)
                lineTo(cx + s * 0.88f, cy - s * 0.72f)
            }
            canvas.drawPath(path, checkPaint)
        }
    }

    private inner class OverlayTouchListener : View.OnTouchListener {
        private var initialX = 0
        private var initialY = 0
        private var initialTouchX = 0f
        private var initialTouchY = 0f
        private var isScaling = false
        private var lastTapTime = 0L

        private val scaleDetector = ScaleGestureDetector(
            this@OverlayService,
            object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
                override fun onScaleBegin(detector: ScaleGestureDetector): Boolean {
                    isScaling = true
                    return true
                }

                override fun onScale(detector: ScaleGestureDetector): Boolean {
                    val newSize = (buttonSizePx * detector.scaleFactor).toInt()
                    buttonSizePx = newSize.coerceIn(dpToPx(SIZE_DP_MIN), dpToPx(SIZE_DP_MAX))
                    updateButtonSize()
                    return true
                }

                override fun onScaleEnd(detector: ScaleGestureDetector) {
                    isScaling = false
                }
            }
        )

        override fun onTouch(v: View, event: MotionEvent): Boolean {
            scaleDetector.onTouchEvent(event)

            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams.x
                    initialY = layoutParams.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                }
                MotionEvent.ACTION_MOVE -> {
                    if (!isScaling && event.pointerCount == 1) {
                        layoutParams.x = initialX + (event.rawX - initialTouchX).toInt()
                        layoutParams.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager.updateViewLayout(overlayView, layoutParams)
                    }
                }
                MotionEvent.ACTION_UP -> {
                    if (!isScaling) {
                        val dx = event.rawX - initialTouchX
                        val dy = event.rawY - initialTouchY
                        if (Math.sqrt((dx * dx + dy * dy).toDouble()) <= TAP_THRESHOLD_PX) {
                            handleTap()
                        }
                    }
                }
            }
            return true
        }

        private fun handleTap() {
            val now = System.currentTimeMillis()
            if (overlayView.state != ButtonState.IDLE) return
            if (now - lastTapTime < DEBOUNCE_MS) return
            lastTapTime = now

            mainHandler.post { overlayView.state = ButtonState.RECORDING }

            Thread {
                try {
                    val location = LocationHelper.fetchLocation(applicationContext)
                    if (location != null) {
                        StorageHelper.savePin(
                            applicationContext,
                            location.latitude,
                            location.longitude,
                            System.currentTimeMillis()
                        )
                    }
                    mainHandler.post { overlayView.state = ButtonState.COMPLETE }
                    mainHandler.postDelayed({
                        overlayView.state = ButtonState.IDLE
                    }, COMPLETE_DISPLAY_MS)
                } catch (_: Exception) {
                    mainHandler.post { overlayView.state = ButtonState.IDLE }
                }
            }.start()
        }
    }
}
