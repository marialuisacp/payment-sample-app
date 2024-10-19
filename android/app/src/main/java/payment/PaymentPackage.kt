package payment

import android.content.Context
import android.view.View
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ReactShadowNode
import com.facebook.react.uimanager.ViewManager
import com.samplepaymentapp.MainApplication

class PaymentPackage(
    private val context: Context,
    private val application: MainApplication
) : ReactPackage {

    override fun createNativeModules(
        reactContext: ReactApplicationContext
    ) = mutableListOf(
        PaymentModule(reactContext, context, application)
    )

    override fun createViewManagers(
        reactContext: ReactApplicationContext
    ): MutableList<ViewManager<View, ReactShadowNode<*>>> = mutableListOf()
}
