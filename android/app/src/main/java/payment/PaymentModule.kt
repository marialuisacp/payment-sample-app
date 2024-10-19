package payment

import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.google.android.gms.wallet.AutoResolveHelper
import com.google.android.gms.wallet.PaymentDataRequest
import com.google.android.gms.wallet.PaymentsClient
import com.samplepaymentapp.MainApplication

class PaymentModule(
    private val reactContext: ReactApplicationContext,
    private val appContext: Context,
    private val application: MainApplication
) : ReactContextBaseJavaModule() {
    private var requestPaymentPromise: Promise? = null
    private val mPaymentsClient: PaymentsClient = PaymentsUtil.createPaymentsClient(appContext)
    private val LOAD_PAYMENT_DATA_REQUEST_CODE = 991
    override fun getName(): String = "PaymentModule"

    @RequiresApi(Build.VERSION_CODES.S)
    @ReactMethod
    fun openPayment(total: Double) {
        val paymentDataRequestJson = PaymentsUtil.getPaymentDataRequest(total.toLong())
        val paymentDataRequest = PaymentDataRequest.fromJson(paymentDataRequestJson.toString())
        if (paymentDataRequest != null) {
            AutoResolveHelper.resolveTask(
                this.mPaymentsClient.loadPaymentData(paymentDataRequest),
                reactContext.currentActivity,
                LOAD_PAYMENT_DATA_REQUEST_CODE
            )
        }
    }
}
